require 'rexml/document'

module EagleCAD
    class Part
	attr_accessor :name, :library, :deviceset, :device, :technology, :value

	def self.from_xml(element)
	    Part.new(element.attributes['name'], element.attributes['library'], element.attributes['deviceset'], element.attributes['device']).tap do |part|
		part.technology = element.attributes['technology'] if element.attributes['technology']
		part.value = element.attributes['value'] if element.attributes['value']
	    end
	end

	def initialize(name, library, deviceset, device)
	    @name = name
	    @library = library
	    @deviceset = deviceset
	    @device = device
	    @technology = ''
	end

	def to_xml
	    REXML::Element.new('part').tap do |element|
		element.add_attributes({'name' => name, 'library' => library, 'deviceset' => deviceset, 'device' => device, 'technology' => technology})
		element.add_attribute('value', value) if value
	    end
	end
    end
end