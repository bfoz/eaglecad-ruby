require 'rexml/document'

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
		super options[:center], options[:radius]
	    end

	    # @return [REXML::Element]
	    def to_xml
		REXML::Element.new('circle').tap {|element| element.add_attributes({'x' => Geometry.format(center.x), 'y' => Geometry.format(center.y), 'radius' => Geometry.format(radius), 'width' => line_width}) }
	    end
	end

	class Frame < ::Geometry::Rectangle
	    # @!attribute columns
	    #   @return [Number]  the number of columns
	    attr_accessor :columns

	    # @!attribute rows
	    #   @return [Number]  the number of rows
	    attr_accessor :rows

	    # @!attribute bottom_border
	    #   @return [Bool]  does the {Frame} have a bottom border?
	    attr_accessor :bottom_border

	    # @!attribute left_border
	    #   @return [Bool]  does the {Frame} have a left border?
	    attr_accessor :left_border

	    # @!attribute right_border
	    #   @return [Bool]  does the {Frame} have a right border?
	    attr_accessor :right_border

	    # @!attribute top_border
	    #   @return [Bool]  does the {Frame} have a top border?
	    attr_accessor :top_border

	    # Create a {Frame} from an {REXML::Element}
	    # @param [Element] element	The {REXML::Element} to parse
	    def self.from_xml(element)
		self.new(from: Geometry.point_from(element, 'x1', 'y1'),
			 to: Geometry.point_from(element, 'x2', 'y2'),
			 columns: element.attributes['columns'],
			 rows: element.attributes['rows'],
			 bottom: element.attributes['border-bottom'],
			 left: element.attributes['border-left'],
			 right: element.attributes['border-right'],
			 top: element.attributes['border-top'])
	    end

	    def initialize(options={})
		@columns = options.delete(:columns) || raise(ArgumentError, "Frame requires columns")
		@rows = options.delete(:rows) || raise(ArgumentError, "Frame requires rows")

		@top_border, @left_border, @bottom_border, @right_border = [:top, :left, :bottom, :right].map {|key| options.key?(key) ? (options.delete(key) == 'yes') : true }

		super options[:from], options[:to]
	    end

	    # @return [REXML::Element]
	    def to_xml
		REXML::Element.new('frame').tap do |element|
		    element.add_attributes('x1' => Geometry.format(origin.x),
					   'y1' => Geometry.format(origin.y),
					   'x2' => Geometry.format(max.x),
					   'y2' => Geometry.format(max.y),
					   'columns' => Geometry.format(columns),
					   'rows' => Geometry.format(rows) )
		    element.add_attribute('border-bottom', 'no') unless bottom_border
		    element.add_attribute('border-left', 'no') unless left_border
		    element.add_attribute('border-right', 'no') unless right_border
		    element.add_attribute('border-top', 'no') unless top_border
		end
	    end
	end

	Hole = Struct.new :origin, :drill do
	    def self.from_xml(element)
		Geometry::Hole.new Geometry.point_from(element, 'x', 'y'), element.attributes['drill']
	    end

	    # @return [REXML::Element]
	    def to_xml
		REXML::Element.new('hole').tap {|element| element.add_attributes({'x' => Geometry.format(origin.x), 'y' => Geometry.format(origin.y), 'drill' => drill}) }
	    end
	end

	class Line < ::Geometry::TwoPointLine
	    attr_accessor :cap, :curve, :line_width

	    # Create a {Line} from an {REXML::Element}
	    # @param [Element] element	The {REXML::Element} to parse
	    def self.from_xml(element)
	    self.new(from:Geometry.point_from(element, 'x1', 'y1'), to:Geometry::point_from(element, 'x2', 'y2'), line_width:element.attributes['width'].to_f, cap: element.attributes['cap'], curve: element.attributes['curve'].to_f)
	    end

	    def initialize(options={})
		@cap = options.delete :cap
		@curve = options.delete :curve
		@line_width = options.delete(:line_width)
		super options[:from], options[:to]
	    end

	    # @return [REXML::Element]
	    def to_xml
		REXML::Element.new('wire').tap do |element|
		    element.add_attributes({'x1' => Geometry.format(first.x), 'y1' => Geometry.format(first.y), 'x2' => Geometry.format(last.x), 'y2' => Geometry.format(last.y), 'width' => line_width})
		    element.add_attribute('cap', cap) unless 'round' == cap
		    element.add_attribute('curve', curve) unless  0 == curve
		end
	    end
	end

	Pad = Struct.new :diameter, :drill, :name, :origin, :rotation, :shape do
	    def self.from_xml(element)
		origin = Geometry.point_from(element, 'x', 'y')
		Geometry::Pad.new(element.attributes['diameter'], element.attributes['drill'], element.attributes['name'], origin, element.attributes['rot'], element.attributes['shape'])
	    end

	    # @return [REXML::Element]
	    def to_xml
		REXML::Element.new('pad').tap do |element|
		    element.add_attributes({'name' => name, 'x' => Geometry.format(origin.x), 'y' => Geometry.format(origin.y), 'diameter' => diameter, 'drill' => drill, 'shape' => shape})
		    element.add_attribute('rot', rotation) unless 'R0' == rotation
		end
	    end
	end

	Pin = Struct.new :direction, :function, :length, :name, :origin, :swaplevel, :rotation, :visible do
	    def self.from_xml(element)
		origin = Geometry.point_from(element, 'x', 'y')
		Geometry::Pin.new(element.attributes['direction'], element.attributes['function'], element.attributes['length'], element.attributes['name'], origin, element.attributes['swaplevel'], element.attributes['rot'], element.attributes['visible'])
	    end

	    # @return [REXML::Element]
	    def to_xml
		REXML::Element.new('pin').tap do |element|
		    element.add_attributes({'name' => name,
					    'x' => Geometry.format(origin.x),
					    'y' => Geometry.format(origin.y),
					    'direction' => direction,
					    'function' => function,
					    'length' => length,
					    'swaplevel' => swaplevel,
					    'rot' => rotation,
					    'visible' => visible})
		end
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

	    # @return [REXML::Element]
	    def to_xml
		REXML::Element.new('polygon').tap do |element|
		    element.add_attribute 'width', line_width
		    vertices.each {|vertex| element.add_element('vertex', {'x' => Geometry.format(vertex.x), 'y' => Geometry.format(vertex.y)}) }
		end
	    end
	end

	class Rectangle < ::Geometry::Rectangle
	    # Create a {Rectangle} from an {REXML::Element}
	    # @param [Element] element	The {REXML::Element} to parse
	    def self.from_xml(element)
		first = Geometry.point_from(element, 'x1', 'y1')
		last = Geometry.point_from(element, 'x2', 'y2')
		self.new(first, last)
	    end

	    # @return [REXML::Element]
	    def to_xml
		REXML::Element.new('rectangle').tap {|element| element.add_attributes({'x1' => Geometry.format(origin.x),
										       'y1' => Geometry.format(origin.y),
										       'x2' => Geometry.format(max.x),
										       'y2' => Geometry.format(max.y)}) }
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
		    smd.rotation = element.attributes['rot']
		    smd.roundness = element.attributes['roundness'].to_i
		    smd.stop = ('no' != element.attributes['stop'])
		    smd.thermals = ('no' != element.attributes['thermals'])
		end
	    end

	    # @return [REXML::Element]
	    def to_xml
		REXML::Element.new('smd').tap do |element|
		    element.add_attributes({'name' => name,
					    'x' => Geometry.format(origin.x),
					    'y' => Geometry.format(origin.y),
					    'dx' => Geometry.format(size.width),
					    'dy' => Geometry.format(size.height)})
		    element.add_attribute('cream', 'no') unless cream
		    element.add_attribute('rot', rotation) if rotation
		    element.add_attribute('roundness', Geometry.format(roundness)) unless 0 == roundness
		    element.add_attribute('stop', 'no') unless stop
		    element.add_attribute('thermals', 'no') unless thermals
		end
	    end
	end

	class Text
	    attr_accessor :align, :distance, :origin, :font, :layer, :ratio, :rotation, :size, :text

	    def self.from_xml(element)
		Geometry::Text.new(Geometry.point_from(element, 'x', 'y'), element.attributes['layer'], element.attributes['size'].to_f, element.text).tap do |object|
		    object.align = element.attributes['align'] || object.align
		    object.distance = element.attributes['distance'] || object.distance
		    object.font = element.attributes['font'] || object.font
		    object.ratio = element.attributes['ratio'] || object.ratio
		    object.rotation = element.attributes['rot'] || object.rotation
		end
	    end

	    def initialize(origin, layer, size, text, options={})
		@origin = origin
		@layer = layer
		@size = size
		@text = text

		@align = options['align'] || 'bottom-left'
		@distance = options['distance'] || 50
		@font = options['font'] || 'proportional'
		@ratio = options['ratio'] || 8
		@rotation = options['rot'] || 'R0'
	    end

	    # @return [REXML::Element]
	    def to_xml
		REXML::Element.new('text').tap do |element|
		    element.add_attributes({'x' => Geometry.format(origin.x), 'y' => Geometry.format(origin.y), 'layer' => layer, 'size' => Geometry.format(size)})
		    element.add_attribute('align', align)
		    element.add_attribute('distance', distance)
		    element.add_attribute('font', font)
		    element.add_attribute('ratio', ratio)
		    element.add_attribute('rot', rotation)
		    element.text = text
		end
	    end
	end

	def self.from_xml(element)
	    case element.name
		when 'circle'
		    Geometry::Circle.from_xml(element)
		when 'frame'	then Geometry::Frame.from_xml(element)
		when 'hole'
		    Geometry::Hole.from_xml(element)
		when 'pad'
		    Geometry::Pad.from_xml(element)
		when 'pin'
		    Geometry::Pin.from_xml(element)
		when 'polygon'
		    Geometry::Polygon.from_xml(element)
		when 'rectangle'
		    Geometry::Rectangle.from_xml(element)
		when 'smd'
		    Geometry::SMD.from_xml(element)
		when 'text'
		    Geometry::Text.from_xml(element)
		when 'wire'
		    Geometry::Line.from_xml(element)
		else
		    raise ArgumentError, "Unrecognized element '#{element.name}'"
	    end
	end

	# Create a {Point} from the given {REXML::Element} using the passed attribute names
	# @param [REXML::Element] element  The {REXML::Element} to parse
	# @param [String] x_name    The name of the attribute containing the X coordinate
	# @param [String] y_name    The name of the attribute containing the Y coordinate
	def self.point_from(element, x_name='x', y_name='y')
	    Point[element.attributes[x_name].to_f, element.attributes[y_name].to_f]
	end

	def self.format(value)
	    "%g" % value
	end
    end
end
