require_relative 'geometry'

module EagleCAD
    Point = ::Geometry::Point
    Size = ::Geometry::Size

    class Package
	attr_accessor :name, :description
	attr_reader :holes, :layers, :pads

	# Create a new {Package} from an {REXML::Element}
	# @param [REXML::Element] element	The {REXML::Element} to parse
	def self.from_xml(element)
	    package = Package.new element.attributes['name']

	    element.elements.each do |element|
		layer_number = element.attributes['layer'].to_i if element.attributes.has_key?('layer')
		case element.name
		    when 'description'
			package.description = element.text
		    when 'hole'
			package.holes.push Geometry::Hole.from_xml(element)
		    when 'pad'
			package.pads.push Geometry::Pad.from_xml(element)
		    else
			g = Geometry.from_xml(element)
			if g
			    package.push layer_number, g
			else
			    raise StandardError, "Unrecognized package element '#{element.name}'"
			end
		end
	    end

	    package
	end

	# @param [String] name	The name of the {Package}
	def initialize(name)
	    @holes = []
	    @layers = {}
	    @layers.default_proc = proc {|hash, key| hash[key] = []}
	    @name = name
	    @pads = []
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