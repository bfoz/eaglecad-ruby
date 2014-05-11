require 'rexml/document'

require_relative 'attribute'
require_relative 'clearance'
require_relative 'design_rules'
require_relative 'library'

module EagleCAD
    class Board
	attr_accessor :design_rules, :description
	attr_reader :attributes, :classes, :elements, :libraries, :passes, :plain

	# @!attribute errors
	#   @return [Array<String>]  error strings that were stored in the 'errors' section of the file
	attr_accessor :errors

	ContactReference = Struct.new :element, :pad, :route, :route_tag
	Via = Struct.new :origin, :extent, :drill

	class Element
	    attr_accessor :name, :library, :package, :value, :origin, :locked, :smashed, :rotation
	    attr_reader :attributes, :variants

	    def self.from_xml(element)
		self.new(element.attributes['name'], element.attributes['library'], element.attributes['package'], element.attributes['value'], Geometry.point_from(element)).tap do |object|
		    element.elements.each do |element|
			case element.name
			    when 'attribute'
				object.attributes.push Attribute.from_xml(element)
			    when 'variant'
				variants = {}
				element.attributes.each {|name, value| variants[name] = value }
				object.variants.push variants
			    else
				raise StandardError, "Unrecognized Element element '#{element.name}'"
			end
		    end
		end
	    end

	    def initialize(name, library, package, value, origin)
		@name = name
		@library = library
		@package = package
		@value = value
		@origin = origin
		@locked = false
		@smashed = false
		@rotation = 0

		@attributes = []
		@variants = []
	    end

	    # @return [REXML::Element]
	    def to_xml
		REXML::Element.new('element').tap do |element|
		    element.add_attributes({'name' => name, 'library' => library, 'package' => package, 'value' => value, 'x' => origin.x, 'y' => origin.y})
		    element.add_attribute('rot', "R#{rotation}") if 0 != rotation
		    element.add_attribute('locked', 'yes') if locked
		    element.add_attribute('smashed', 'yes') if smashed

		    attributes.each {|attribute| element.add_element attribute.to_xml }
		    variants.each {|variant| element.add_element('variant', variant)}
		end
	    end
	end

	class Signal
	    attr_accessor :air_wires_hidden, :clearance_class, :name
	    attr_reader :contact_references, :vias

	    def self.from_xml(element)
		self.new(element.attributes['name']).tap do |signal|
		    element.attributes.each do |name, value|
			case name
			    when 'airwireshidden'
				signal.air_wires_hidden = ('no' != value)
			    when 'class'
				signal.clearance_class = value.to_i
			    when 'name'	# Ignore; already handled
			    else
				raise StandardError, "Unrecognized Signal element '#{element.name}'"
			end
		    end

		    element.elements.each do |element|
			case element.name
			    when 'contactref'
				signal.contact_references.push ContactReference.new element.attributes['element'], element.attributes['pad'], element.attributes['route'], element.attributes['routetag']
			    when 'polygon', 'wire'
				signal.push Geometry.from_xml(element)
			    when 'via'
				signal.vias.push Via.new Geometry.from_point(element), element.attributes['extent'], element.attributes['drill']
			end
		    end
		end
	    end

	    def initialize(name)
		@contact_references = []
		@name = name
		@vias = []
	    end
	end

	def self.from_xml(element)
	    Board.new.tap do |board|
		element.elements.each do |element|
		    case element.name
			when 'attributes'
			    element.elements.each {|attribute| board.attributes.push Attribute.from_xml(attribute) }
			when 'autorouter'
			    element.elements.each do |pass_element|
				pass = board.passes[pass_element.attributes['name']]
				pass_element.elements.each {|parameter| pass[parameter.attributes['name']] = parameter.attributes['value'] }
			    end
			when 'classes'
			    element.elements.each {|clearance| board.classes.push Clearance.from_xml(clearance) }
			when 'description'
			    board.description = element.text
			when 'designrules'
			    board.design_rules = DesignRules.from_xml(element)
			when 'elements'
			    element.elements.each {|object| board.elements.push Element.from_xml(object) }
			when 'errors'
			    element.elements.each {|approved| board.errors.push approved.attributes['hash'] }
			when 'libraries'
			    element.elements.each {|library| board.libraries[library.attributes['name']] = Library.from_xml(library) }
			when 'plain'
			    element.elements.each {|object| board.plain.push Geometry.from_xml(object) }
			when 'signals'
			when 'variantdefs'
			else
			    raise StandardError, "Unrecognized Board element '#{element.name}'"
		    end
		end
	    end
	end

	def initialize
	    @attributes = []
	    @classes = []
	    @contact_references = []
	    @elements = []
	    @errors = []
	    @libraries = {}
	    @passes = Hash.new {|hash, key| hash[key] = Hash.new }
	    @plain = []
	end

	# @return [REXML::Element]
	def to_xml
	    REXML::Element.new('board').tap do |element|
		element.add_element('attributes').tap do |attribute_element|
		    attributes.each {|attribute| attribute_element.add_element attribute.to_xml }
		end

		element.add_element('description').text = description

		element.add_element('autorouter').tap do |autorouter_element|
		    passes.each do |name, pass|
			autorouter_element.add_element('pass', {'name' => name}).tap do |pass_element|
			    pass.each {|name, value| pass_element.add_element('param', {'name' => name, 'value' => value})}
			end
		    end
		end

		element.add_element('classes').tap do |classes_element|
		    classes.each do |clearance|
			classes_element.add_element clearance.to_xml
		    end
		end

		element.add_element(design_rules.to_xml) if design_rules

		element.add_element('elements').tap do |element_element|
		    elements.each {|object| element_element.add_element object.to_xml }
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

		element.add_element('libraries').tap do |libraries_element|
		    libraries.each {|name, library| libraries_element.add_element library.to_xml }
		end

		element.add_element('plain').tap do |plain_element|
		    plain.each {|object| plain_element.add_element object.to_xml }
		end
	    end
	end
    end
end
