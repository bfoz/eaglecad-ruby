require_relative 'attribute'
require_relative 'geometry'

module EagleCAD
    class Sheet
	attr_accessor :description
	attr_reader :busses, :instances, :nets

	PinReference = Struct.new :part, :gate, :pin

	class Bus
	    attr_accessor :name
	    attr_reader :segments

	    def self.from_xml(element)
		Bus.new(element.attributes['name']).tap do |bus|
		    element.elements.each {|segment| bus.segments.push Segment.from_xml(segment) }
		end
	    end

	    def initialize(name)
		@name = name
		@segments = []
	    end
	end

	class Instance
	    attr_accessor :part, :gate, :origin, :smashed, :rotation
	    attr_reader :attributes

	    def self.from_xml(element)
		Instance.new(element.attributes['part'], element.attributes['gate'], Geometry.point_from(element)).tap do |instance|
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
		@rotation = 0
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
			    when 'rotation' then label.rotation = value
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
		@rotation = 0
		@cross_reference = false
	    end
	end

	class Net
	    attr_accessor :clearance_class, :name
	    attr_reader :segments

	    def self.from_xml(element)
		Net.new(element.attributes['name'], element.attributes['class'].to_i).tap do |net|
		    element.elements.each {|segment| net.segments.push Segment.from_xml(segment) }
		end
	    end

	    def initialize(name, clearance_class)
		@clearance_class = clearance_class
		@name = name
		@segments = []
	    end
	end

	class Segment
	    attr_reader :elements

	    def self.from_xml(element)
		Segment.new.tap do |segment|
		    element.elements.each do |element|
			case element.name
			    when 'pinref'
				segment.elements.push PinReference.new element.attributes['part'], element.attributes['gate'], element.attributes['pin']
			    when 'wire'
				segment.elements.push Geometry::Line.from_xml(element)
			    when 'junction'
				segment.elements.push Geometry.point_from(element)
			    when 'label'
				segment.elements.push Label.from_xml(element)
			    else
				raise StandardError, "Unrecognized Segment element '#{element.name}"
			end
		    end
		end
	    end

	    def initialize
		@elements = []
	    end
	end

	def self.from_xml(element)
	    Sheet.new.tap do |sheet|
		element.elements.each do |element|
		    case element.name
			when 'busses'
			    element.elements.each {|bus| sheet.push Bus.from_xml(bus) }
			when 'description'
			    sheet.description = element.text
			when 'instances'
			    element.elements.each {|instance| sheet.push Instance.from_xml(instance) }
			when 'nets'
			    element.elements.each {|part| sheet.push Net.from_xml(part) }
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
    end
end
