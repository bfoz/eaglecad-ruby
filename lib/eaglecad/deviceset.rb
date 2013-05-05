require_relative 'geometry'

module EagleCAD
    class DeviceSet
	attr_accessor :description, :name, :prefix, :uservalue
	attr_reader :devices, :gates

	Connect = Struct.new :gate, :pin, :pad, :route do
	    def self.from_xml(element)
		Connect.new element.attributes['gate'], element.attributes['pin'], element.attributes['pad'], element.attributes['route']
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
	end

	Gate = Struct.new :name, :symbol, :origin, :addlevel, :swaplevel do
	    def self.from_xml(element)
		Gate.new element.attributes['name'], element.attributes['symbol'], Geometry.point_from(element, 'x', 'y'), element.attributes['addlevel'], element.attributes['swaplevel']
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
    end
end
