require_relative 'deviceset'
require_relative 'package'
require_relative 'symbol'

module EagleCAD
    class Library
	attr_accessor :description, :name, :packages, :symbols, :device_sets

	# Create a new {Library} from an {REXML::Element}
	# @param [REXML::Element] element	The {REXML::Element} to parse
	def self.from_xml(element)
	    Library.new(name:element.attributes['name']).tap do |library|
		library.description = element.elements['description']

		element.elements['packages'].elements.each {|package| library.push Package.from_xml(package) }
		element.elements['symbols'].elements.each {|symbol| library.push Symbol.from_xml(symbol) }
		element.elements['devicesets'].elements.each {|symbol| library.push DeviceSet.from_xml(symbol) }
	    end
	end

	def initialize(options={})
	    options.each {|k,v| send("#{k}=", v) }

	    @device_sets = []
	    @packages = {}
	    @symbols = []
	end

	def push(arg)
	    case arg
		when DeviceSet
		    @device_sets.push arg
		when Package
		    @packages[arg.name] = arg
		when Symbol
		    @symbols.push arg
	    end
	end
    end
end
