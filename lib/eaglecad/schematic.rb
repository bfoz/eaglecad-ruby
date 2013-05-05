require 'rexml/document'

require_relative 'attribute'
require_relative 'geometry'

module EagleCAD
    class Schematic
	attr_accessor :description
	attr_reader :attributes, :classes, :libraries, :parts, :sheets

	class ClearanceClass
	    attr_accessor :name, :number, :width, :drill
	    attr_reader :values

	    def self.from_xml(element)
		ClearanceClass.new(element.attributes['name'], element.attributes['number'].to_i).tap do |clearance|
		    clearance.width = (element.attributes['width'] || 0).to_f
		    clearance.drill = (element.attributes['drill'] || 0).to_f
		end
	    end

	    def initialize(name, number)
		@name = name
		@number = number
		@values = []
	    end
	end

	class Part
	    attr_accessor :name, :library, :deviceset, :device, :technology, :value

	    def self.from_xml(element)
		Part.new(element.attributes['name'], element.attributes['library'], element.attributes['deviceset'], element.attributes['device'])
	    end

	    def initialize(name, library, deviceset, device)
		@name = name
		@library = library
		@deviceset = deviceset
		@device = device
	    end
	end

	# Create a new {Schematic} from an {REXML::Element}
	# @param [REXML::Element] element	The {REXML::Element} to parse
    	def self.from_xml(element)
	    Schematic.new.tap do |schematic|
		element.elements.each do |element|
		    case element.name
			when 'attributes'
			    element.elements.each {|attribute| schematic.attributes.push Attribute.from_xml(attribute) }
			when 'classes'
			    element.elements.each {|clearance| schematic.classes.push ClearanceClass.from_xml(clearance) }
			when 'description'
			    schematic.description = element.text
			when 'libraries'
			    element.elements.each {|library| schematic.libraries[library.attributes['name']] = Library.from_xml(library) }
			when 'parts'
			    element.elements.each {|part| schematic.parts.push Part.from_xml(part) }
			when 'sheets'
			    element.elements.each {|sheet| schematic.sheets.push Sheet.from_xml(sheet) }
			when 'variantdefs'
			else
			    raise StandardError, "Unrecognized element '#{element.name}'"
		    end
		end
	    end
	end

	def initialize
	    @attributes = []
	    @classes = []
	    @libraries = {}
	    @parts = []
	    @sheets = []
	end
    end
end
