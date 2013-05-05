require_relative 'geometry'

module EagleCAD
    class Symbol
	attr_accessor :name, :description
	attr_reader :layers, :pins

	# Create a new {Symbol} from an {REXML::Element}
	# @param [Element] element  The {REXML::Element} to parse
	def self.from_xml(element)
	    symbol = Symbol.new element.attributes['name']

	    element.elements.each do |element|
		layer_number = element.attributes['layer'].to_i if element.attributes.has_key?('layer')
		case element.name
		    when 'circle'
			symbol.push layer_number, Geometry::Circle.from_xml(element)
		    when 'description'
			symbol.description = element.text
		    when 'pin'
			symbol.pins.push Geometry::Pin.from_xml(element)
		    when 'polygon'
			symbol.push layer_number, Geometry::Polygon.from_xml(element)
		    when 'rectangle'
			symbol.push layer_number, Geometry::Rectangle.from_xml(element)
		    when 'smd'
			symbol.push layer_number, Geometry::SMD.from_xml(element)
		    when 'text'
			symbol.push layer_number, Geometry::Text.from_xml(element)
		    when 'wire'
			symbol.push layer_number, Geometry::Line.from_xml(element)
		    else
			raise StandardError, "Unrecognized symbol element '#{element.name}'"
		end
	    end

	    symbol
	end

	# @param [String] name	The name of the {Package}
	def initialize(name)
	    @layers = {}
	    @layers.default_proc = proc {|hash, key| hash[key] = []}
	    @name = name
	    @pins = []
	end

	# Push a new element to the given layer number
	# @param [Numeric] layer_number	The layer to add the element to
	# @param [Object] element   The thing to push
	def push(layer_number, element)
	    layer = @layers[layer_number]
	    layer.push element
	end
    end
end
