require 'rexml/document'

require_relative 'geometry'

module EagleCAD
    class DeviceSet
	attr_accessor :description, :name, :prefix, :uservalue
	attr_reader :devices, :gates

	Connect = Struct.new :gate, :pin, :pad, :route do
	    def self.from_xml(element)
		Connect.new element.attributes['gate'], element.attributes['pin'], element.attributes['pad'], element.attributes['route']
	    end

	    # @return [REXML::Element]
	    def to_xml
		REXML::Element.new('connect').tap {|element| element.add_attributes({'gate' => gate, 'pad' => pad, 'pin' => pin}) }
	    end
	end
	
	class Device
	    attr_accessor :name, :package
	    attr_reader :connects, :technologies

	    def self.from_xml(element)
		Device.new(element.attributes['name']).tap do |device|
		    device.package = element.attributes['package']

		    element.elements.each do |element|
			case element.name
			    when 'connects'
				element.elements.each {|connect| device.connects.push Connect.from_xml(connect) }
			    when 'technologies'
				element.elements.each {|technology| device.technologies.push technology.attributes['name'] }
			end
		    end
		end
	    end

	    def initialize(name)
		@connects = []
		@name = name
		@technologies = []
	    end

	    # Generate XML for the {DeviceSet} element
	    # @return [REXML::Element]
	    def to_xml
		REXML::Element.new('device').tap do |element|
		    element.add_attributes({'name' => name, 'package' => package})

		    connects_element = element.add_element('connects')
		    connects.each {|connect| connects_element.add_element connect.to_xml }

		    technologies_element = element.add_element('technologies')
		    technologies.each {|technology| technologies_element.add_element('technology', {'name' => technology}) }
		end
	    end
	end

	Gate = Struct.new :name, :symbol, :origin, :addlevel, :swaplevel do
	    def self.from_xml(element)
		Gate.new element.attributes['name'], element.attributes['symbol'], Geometry.point_from(element, 'x', 'y'), element.attributes['addlevel'], element.attributes['swaplevel']
	    end

	    # @return [REXML::Element]
	    def to_xml
		REXML::Element.new('gate').tap {|element| element.add_attributes({'name' => name, 'symbol' => symbol, 'x' => origin.x, 'y' => origin.y, 'addlevel' => addlevel, 'swaplevel' => swaplevel}) }
            end
	end

	# Create a new {DeviceSet} from an {REXML::Element}
	# @param [Element] element  The {REXML::Element} to parse
	def self.from_xml(element)
	    DeviceSet.new(element.attributes['name']).tap do |deviceset|
		deviceset.prefix = element.attributes['prefix']
		deviceset.uservalue = ('yes' == element.attributes['uservalue'])

		element.elements.each do |element|
		    case element.name
			when 'devices'
			    element.elements.each {|device| deviceset.devices.push Device.from_xml(device) }
			when 'description'
			    deviceset.description = element.text
			when 'gates'
			     element.elements.each {|gate| deviceset.gates.push Gate.from_xml(gate) }
		    end
		end
	    end
	end

	def initialize(name)
	    @devices = []
	    @gates = []
	    @name = name
	end

	# Generate XML for the {DeviceSet} element
	# @return [REXML::Element]
	def to_xml
	    REXML::Element.new('deviceset').tap do |element|
		element.add_attributes({'name' => name, 'prefix' => prefix, 'uservalue' => (uservalue ? 'yes' : 'no')})
		element.add_element('description').text = description

		gates_element = element.add_element('gates')
		gates.each {|gate| gates_element.add_element gate.to_xml }

		devices_element = element.add_element('devices')
		devices.each {|device| devices_element.add_element device.to_xml }
	    end
	end
    end
end
