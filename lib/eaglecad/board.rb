require_relative 'attribute'
require_relative 'clearance'
require_relative 'design_rules'
require_relative 'library'

module EagleCAD
    class Board
	attr_accessor :design_rules, :description
	attr_reader :attributes, :classes, :elements, :libraries, :passes, :plain

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
			    element.elements.each do |element|
				pass = board.passes[element.attributes['name']]
				element.elements.each {|parameter| pass[parameter.attributes['name']] = parameter.attributes['value'] }
			    end
			when 'classes'
			    element.elements.each {|clearance| board.classes.push Clearance.from_xml(clearance) }
			when 'description'
			    board.description = element.text
			when 'designrules'
			    board.design_rules = DesignRules.from_xml(element)
			when 'elements'
			    element.elements.each {|object| board.elements.push Element.from_xml(object) }
			when 'libraries'
			    element.elements.each {|library| board.libraries[library.attributes['name']] = Library.from_xml(library) }
			when 'plain'
			    board.plain.push Geometry.from_xml(element)
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
	    @libraries = {}
	    @passes = Hash.new {|hash, key| hash[key] = Hash.new }
	    @plain = []
	end
    end
end
