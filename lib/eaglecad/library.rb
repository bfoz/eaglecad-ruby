require 'rexml/document'

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
		description = element.elements['description']
		library.description = description.text if description

		element.elements.each do |element|
		    case element.name
			when 'devicesets'
			    element.elements.each {|symbol| library.push DeviceSet.from_xml(symbol) }
			when 'packages'
			    element.elements.each {|package| library.push Package.from_xml(package) }
			when 'symbols'
			    element.elements.each {|symbol| library.push Symbol.from_xml(symbol) }
		    end
		end
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

	# Generate XML for the {Library} element
	# @return [REXML::Element]
	def to_xml
	    REXML::Element.new('library').tap do |element|
		element.add_attribute 'name', name

		element.add_element('description').text = description if description

		# Packages must be output before devicesets or Eagle will fail to load the file
		element.add_element('packages').tap do |packages_element|
		    packages.each {|name, package| packages_element.add_element package.to_xml }
		end

		# Symbols must be output before devicessets or Eagle will fail to load the file
		element.add_element('symbols').tap do |symbols_element|
		    symbols.each {|symbol| symbols_element.add_element symbol.to_xml }
		end

		if device_sets and device_sets.count
		    element.add_element('devicesets').tap do |devicesets_element|
			device_sets.each {|deviceset| devicesets_element.add_element deviceset.to_xml }
		    end
		end
	    end
	end
    end
end
