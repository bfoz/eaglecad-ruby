require_relative 'attribute'
require_relative 'geometry'

module EagleCAD
    ParseError = Class.new(StandardError)

    class Sheet
	attr_accessor :description
	attr_reader :busses, :instances, :nets

	PinReference = Struct.new :instance, :pin, :net do
	    def self.from_xml(element, net, instances=[])
		gate_name = element.attributes['gate']
		part_name = element.attributes['part']

		instance = instances.find {|instance| (instance.part.name == part_name) && (instance.gate == gate_name)}
		raise ParseError, "Couldn't find an instance for #{part_name}:#{gate_name}" unless instance

		Sheet::PinReference.new instance, element.attributes['pin'], net
	    end

	    def to_xml
		REXML::Element.new('pinref').tap do |element|
		    element.add_attributes('gate' => instance.gate,
					   'part' => instance.part,
					   'pin' => pin)
		end
	    end

	    def to_s
		"#{instance.part.name}.#{pin}"
	    end
	end

	class Bus
	    attr_accessor :name
	    attr_reader :segments

	    def self.from_xml(element, instances)
		Bus.new(element.attributes['name']).tap do |bus|
		    element.elements.each {|segment| bus.segments.push Segment.from_xml(segment, nil, instances) }
		end
	    end

	    def initialize(name)
		@name = name
		@segments = []
	    end

	    def to_xml
		REXML::Element.new('bus').tap do |element|
		    element.add_attribute 'name', name
		    segments.each {|segment| element.add_element segment.to_xml }
		end
	    end
	end

	class Instance
	    # @!attribute part
	    #   @return [Part]  The {Part} that this {Instance} is an instance of
	    attr_accessor :part

	    attr_accessor :gate, :origin, :smashed, :rotation
	    attr_reader :attributes

	    def self.from_xml(element, parts)
		gate_name = element.attributes['gate']
		part_name = element.attributes['part']

		part = parts.find {|part| part.name == part_name }
		raise ParseError, "Couldn't find a Part for #{part_name}:#{gate_name}" unless part

		Instance.new(part, element.attributes['gate'], Geometry.point_from(element)).tap do |instance|
		    element.attributes.each do |name, value|
			case name
			    when 'smashed'  then instance.smashed = ('no' != element.attributes['smashed'])
			    when 'rot'	    then instance.rotation = element.attributes['rot']
			    when 'part', 'gate', 'x', 'y'	# Ignore; already handled
			    else
				raise StandardError, "Unrecognized Instance attribute '#{name}'"
			end
		    end

		    element.elements.each {|attribute| instance.attributes.push Attribute.from_xml(attribute) }
		end
	    end

	    def initialize(part, gate, origin)
		@attributes = []
		@part = part
		@gate = gate
		@origin = origin
		@smashed = false
		@rotation = 'R0'
	    end

	    def to_xml
		REXML::Element.new('instance').tap do |element|
		    element.add_attributes({'part' => part.name, 'gate' => gate, 'x' => origin.x, 'y' => origin.y})
		    element.add_attribute('smashed', 'yes') if smashed
		    element.add_attribute('rot', rotation)

		    attributes.each {|attribute| element.add_element attribute.to_xml }
		end
	    end
	end

	class Label
	    attr_accessor :origin, :size, :layer_number, :font, :ratio, :rotation, :cross_reference

	    def self.from_xml(element)
		Label.new(Geometry.point_from(element), element.attributes['size'].to_f, element.attributes['layer'].to_i).tap do |label|
		    element.attributes.each do |name, value|
			case name
			    when 'font'	    then label.font = value.to_sym
			    when 'ratio'    then label.ratio = value.to_i
			    when 'rot'	    then label.rotation = value
			    when 'xref'	    then label.cross_reference = ('no' != value)
			end
		    end
		end
	    end

	    def initialize(origin, size, layer_number)
		@origin = origin
		@size = size
		@layer_number = layer_number
		@font = :proportional
		@ratio = 8
		@rotation = 'R0'
		@cross_reference = false
	    end

	    def to_xml
		REXML::Element.new('label').tap do |element|
		    element.add_attributes({'x' => origin.x, 'y' => origin.y, 'layer' => layer_number ,'size' => size})
		    element.add_attribute('font', font)
		    element.add_attribute('ratio', ratio) unless 8 == ratio
		    element.add_attribute('rot', rotation)
		    element.add_attribute('xref', cross_reference) if cross_reference
		end
	    end
	end

	class Net
	    attr_accessor :clearance_class, :name
	    attr_reader :segments
	    attr_reader :connections

	    def self.from_xml(element, instances)
		Net.new(element.attributes['name'], element.attributes['class'].to_i).tap do |net|
		    element.elements.each {|segment| net.segments.push Segment.from_xml(segment, net, instances) }
		end
	    end

	    def initialize(name, clearance_class)
		@clearance_class = clearance_class
		@connections = []
		@name = name
		@segments = []
	    end

	    def to_xml
		REXML::Element.new('net').tap do |element|
		    element.add_attribute('name', name)
		    element.add_attribute('class', clearance_class) unless 0 == clearance_class

		    segments.each {|segment| element.add_element segment.to_xml }
		end
	    end

	    # Add a connection to the {Net}
	    # @param pinref [PinReference]  the pin to connect to
	    def connect(pinref)
		connections << pinref
	    end
	end

	class Segment
	    attr_reader :elements, :layers

	    def self.from_xml(element, net, instances)
		Segment.new.tap do |segment|
		    element.elements.each do |element|
			case element.name
			    when 'junction'
				segment.elements.push Geometry.point_from(element)
			    when 'label'
				segment.push element.attributes['layer'], Label.from_xml(element)
			    when 'pinref'
				segment.elements.push PinReference.from_xml(element, net, instances)
				net.connect(segment.elements.last) if net
			    when 'wire'
				segment.push element.attributes['layer'], Geometry::Line.from_xml(element)
			    else
				raise StandardError, "Unrecognized Segment element '#{element.name}"
			end
		    end
		end
	    end

	    def initialize
		@elements = []
		@layers = {}
		@layers.default_proc = proc {|hash, key| hash[key] = []}
	    end

	    # Push a new element to the given layer number
	    # @param [Numeric] layer_number	The layer to add the element to
	    # @param [Object] element   The thing to push
	    def push(layer_number, element)
		layer = @layers[layer_number]
		layer.push element
	    end

	    def to_xml
		REXML::Element.new('segment').tap do |element|
		    elements.each do |object|
			if object.is_a? Point
			    element.add_element('junction', {'x' => object.x, 'y' => object.y})
			else
			    element.add_element object.to_xml
			end
		    end

		    layers.each do |number, layer|
			layer.each {|obj| element.add_element(obj.to_xml, {'layer' => number}) }
		    end
		end
	    end
	end

	def self.from_xml(element, parts)
	    Sheet.new.tap do |sheet|
		element.elements.each do |element|
		    case element.name
			when 'busses'
			    element.elements.each {|bus| sheet.push Bus.from_xml(bus, sheet.instances) }
			when 'description'
			    sheet.description = element.text
			when 'instances'
			    element.elements.each {|instance| sheet.push Instance.from_xml(instance, parts) }
			when 'nets'
			    element.elements.each {|part| sheet.push Net.from_xml(part, sheet.instances) }
			when 'plain' #Ignore
			else
			    raise StandardError, "Unrecognized Sheet element '#{element.name}'"
		    end
		end
	    end
	end

	def initialize
	    @busses = []
	    @instances = []
	    @nets = []
	    @parts = []
	end

	# Add the passed {Sheet} element to the {Sheet}
	def push(arg)
	    case arg
		when Bus	then busses.push arg
		when Instance	then instances.push arg
		when Net	then nets.push arg
		else
		    raise ArgumentError, "Unrecognized object '#{arg.class}'"
	    end
	end

	def to_xml
	    REXML::Element.new('sheet').tap do |element|
		element.add_element('description').text = description

		element.add_element('instances').tap do |instances_element|
		    instances.each {|instance| instances_element.add_element instance.to_xml }
		end

		element.add_element('busses').tap do |busses_element|
		    busses.each {|bus| busses_element.add_element bus.to_xml }
		end

		element.add_element('nets').tap do |nets_element|
		    nets.each {|net| nets_element.add_element net.to_xml }
		end
	    end
	end
    end
end
