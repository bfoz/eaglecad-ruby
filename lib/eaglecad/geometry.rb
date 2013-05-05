require 'geometry'

module EagleCAD
    module Geometry
	Point = ::Geometry::Point

	class Circle < ::Geometry::Circle
	    attr_accessor :line_width

	    # Create a {Circle} from an {REXML::Element}
	    # @param [Element] element	The {REXML::Element} to parse
	    def self.from_xml(element)
		self.new center:Geometry.point_from(element, 'x', 'y'), radius:element.attributes['radius'].to_f, line_width:element.attributes['width'].to_f
	    end

	    def initialize(options={})
		@line_width = options.delete(:line_width)
		super *options
	    end
	end

	Hole = Struct.new :origin, :drill do
	    def self.from_xml(element)
		Geometry::Hole.new Geometry.point_from(element, 'x', 'y'), element.attributes['drill']
	    end
	end

	class Line < ::Geometry::TwoPointLine
	    attr_accessor :line_width

	    # Create a {Line} from an {REXML::Element}
	    # @param [Element] element	The {REXML::Element} to parse
	    def self.from_xml(element)
		self.new(from:Geometry.point_from(element, 'x1', 'y1'), to:Geometry::point_from(element, 'x2', 'y2'), line_width:element.attributes['width'].to_f)
	    end

	    def initialize(options={})
		@line_width = options.delete(:line_width)
		super options[:from], options[:to]
	    end
	end

	Pad = Struct.new :diameter, :drill, :name, :origin, :shape do
	    def self.from_xml(element)
		origin = Geometry.point_from(element, 'x', 'y')
		Geometry::Pad.new(element.attributes['diameter'], element.attributes['drill'], element.attributes['name'], origin, element.attributes['shape'])
	    end
	end

	Pin = Struct.new :direction, :function, :length, :name, :origin, :swaplevel, :rotation, :visible do
	    def self.from_xml(element)
		origin = Geometry.point_from(element, 'x', 'y')
		Geometry::Pin.new(element.attributes['direction'], element.attributes['function'], element.attributes['length'], element.attributes['name'], origin, element.attributes['swaplevel'], element.attributes['rotation'], element.attributes['visible'])
	    end
	end

	class Polygon < ::Geometry::Polygon
	    attr_accessor :line_width

	    # Create a {Polygon} from an {REXML::Element}
	    # @param [Element] element	The {REXML::Element} to parse
	    def self.from_xml(element)
		width = element.attributes['width']
		vertices = element.elements.map {|vertex| Geometry::point_from(vertex, 'x', 'y') }
		self.new(*vertices, line_width:width)
	    end

	    def initialize(*args)
		options, args = args.partition {|a| a.is_a? Hash}
		options = options.reduce({}, :merge)

		@line_width = options.delete(:line_width)

		super *args
	    end
	end

	class Rectangle < ::Geometry::Rectangle
	    # Create a {Rectangle} from an {REXML::Element}
	    # @param [Element] element	The {REXML::Element} to parse
	    def self.from_xml(element)
		first = Geometry.point_from(element, 'x1', 'y1')
		last = Geometry.point_from(element, 'x2', 'y2')
		::Geometry::Rectangle.new(from:first, to:last)
	    end
	end

	class SMD < ::Geometry::SizedRectangle
	    attr_accessor :cream, :name, :roundness, :rotation, :stop, :thermals

	    # Create a {SMD} from an {REXML::Element}
	    # @param [Element] element	The {REXML::Element} to parse
	    def self.from_xml(element)
		size = Size[element.attributes['dx'].to_f, element.attributes['dy'].to_f]
		SMD.new(origin:Geometry.point_from(element, 'x', 'y'), size:size).tap do |smd|
		    smd.cream = ('no' != element.attributes['cream'])
		    smd.name = element.attributes['name']
		    smd.roundness = element.attributes['roundness'].to_i
		    smd.rotation = element.attributes['rot']
		    smd.stop = ('no' != element.attributes['stop'])
		    smd.thermals = ('no' != element.attributes['thermals'])
		end
	    end
	end

	Text = Struct.new :origin, :size, :text do
	    def self.from_xml(element)
		Geometry::Text.new(Geometry.point_from(element, 'x', 'y'), element.attributes['size'].to_f, element.text)
	    end
	end

	# Create a {Point} from the given {REXML::Element} using the passed attribute names
	# @param [REXML::Element] element  The {REXML::Element} to parse
	# @param [String] x_name    The name of the attribute containing the X coordinate
	# @param [String] y_name    The name of the attribute containing the Y coordinate
	def self.point_from(element, x_name='x', y_name='y')
	    Point[element.attributes[x_name].to_f, element.attributes[y_name].to_f]
	end
    end
end
