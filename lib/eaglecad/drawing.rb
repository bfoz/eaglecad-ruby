require_relative 'board'
require_relative 'layer'
require_relative 'schematic'

module EagleCAD
    class Drawing
	attr_accessor :board, :schematic
	attr_reader :layers

	# Grid attributes
	attr_accessor :distance, :unitdistance, :unit, :style, :multiple, :display, :altdistance, :altunitdist, :altunit

	# Settings attributes
	attr_accessor :always_vector_font, :vertical_text

	def self.from_xml(element)
	    self.new.tap do |drawing|
		element.elements.each do |element|
		    case element.name
			when 'board'
			    raise StandardError, "Drawing files must contain only one Board element" if drawing.board
			    drawing.board = Board.from_xml(element)

			when 'grid'
			    element.attributes.each do |name, value|
				case name
				    when 'distance'	then drawing.distance = value.to_f
				    when 'unitdist'	then drawing.unitdistance = value.to_sym
				    when 'unit'		then drawing.unit = value.to_sym
				    when 'style'	then drawing.style = value.to_sym
				    when 'multiple'	then drawing.multiple = value.to_i
				    when 'display'	then drawing.display = ('no' != value)
				    when 'altdistance'  then drawing.altdistance = value.to_f
				    when 'altunitdist'  then drawing.altunitdist = value.to_sym
				    when 'altunit'	then drawing.altunit = value.to_sym
				end
			    end

			when 'layers'
			    element.elements.each {|element| drawing.layers.push Layer.from_xml(element) }

			when 'schematic'
			    raise StandardError, "Drawing files must contain only one Schematic element" if drawing.schematic
			    drawing.schematic = Schematic.from_xml(element)

			when 'settings'
			    element.elements.each do |element|
				element.attributes.each do |name, value|
				    case name
					when 'alwaysvectorfont' then drawing.always_vector_font = ('no' != value)
					when 'verticaltext'	    then drawing.vertical_text = value.to_sym
				    end
				end
			    end

			else
			    raise StandardError, "Unrecognized Drawing element '#{element.name}'"
		    end
		end
	    end
	end

	def initialize()
	    @layers = []
	    self.vertical_text = :up

	    self.display = false
	    self.multiple = 1
	    self.style = :lines
	end
    end
end
