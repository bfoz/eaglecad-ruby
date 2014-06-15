require 'rexml/document'

require_relative 'attribute'
require_relative 'clearance'
require_relative 'geometry'
require_relative 'library'
require_relative 'part'
require_relative 'sheet'

module EagleCAD
    class Schematic
	attr_accessor :description
	attr_reader :attributes, :classes, :libraries, :parts, :sheets

	# @!attribute errors
	#   @return [Array<String>]  error strings that were stored in the 'errors' section of the file
	attr_accessor :errors

	# Create a new {Schematic} from an {REXML::Element}
	# @param [REXML::Element] element	The {REXML::Element} to parse
    	def self.from_xml(element)
	    Schematic.new.tap do |schematic|
		element.elements.each do |element|
		    case element.name
			when 'attributes'
			    element.elements.each {|attribute| schematic.attributes.push Attribute.from_xml(attribute) }
			when 'classes'
			    element.elements.each {|clearance| schematic.classes.push Clearance.from_xml(clearance) }
			when 'description'
			    schematic.description = element.text
			when 'errors'
			    element.elements.each {|approved| schematic.errors.push approved.attributes['hash'] }
			when 'libraries'
			    element.elements.each {|library| schematic.libraries[library.attributes['name']] = Library.from_xml(library) }
			when 'parts'
			    element.elements.each {|part| schematic.parts.push Part.from_xml(part) }
			when 'sheets'
			    element.elements.each {|sheet| schematic.sheets.push Sheet.from_xml(sheet, schematic.parts) }
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
	    @errors = []
	    @libraries = {}
	    @parts = []
	    @sheets = []
	end

	# Generate XML for the {Schematic} element
	# @return [REXML::Element]
	def to_xml
	    REXML::Element.new('schematic').tap do |element|
		element.add_element('description').text = description if description

		# Libraries must be output before parts or Eagle will fail to load the file
		element.add_element('libraries').tap do |libraries_element|
		    libraries.each do |name, library|
			libraries_element.add_element library.to_xml
		    end
		end

		REXML::Element.new('attributes').tap do |attributes_element|
		    attributes.each {|attribute| attributes_element.add_element attribute.to_xml }
		    element.add_element(attributes_element) if attributes_element.has_elements?
		end

		element.add_element('variantdefs')

		element.add_element('classes').tap do |classes_element|
		    classes.each {|object| classes_element.add_element object.to_xml }
		end

		element.add_element('parts').tap do |parts_element|
		    parts.each {|part| parts_element.add_element part.to_xml }
		end

		element.add_element('sheets').tap do |sheets_element|
		    sheets.each {|sheet| sheets_element.add_element sheet.to_xml }
		end

		if errors.length != 0
		    element.add_element('errors').tap do |errors_element|
			errors.each do |approved|
			    errors_element.add_element('approved').tap do |approved_element|
				approved_element.add_attribute('hash', approved)
			    end
			end
		    end
		end
	    end
	end
    end
end
