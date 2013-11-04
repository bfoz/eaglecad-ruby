require 'rexml/document'

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

	# @param element [REXML::Element]
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
				    when 'altdistance'  then drawing.altdistance = value.to_f
				    when 'altunit'	then drawing.altunit = value.to_sym
				    when 'altunitdist'  then drawing.altunitdist = value.to_sym
				    when 'display'	then drawing.display = ('no' != value)
				    when 'distance'	then drawing.distance = value.to_f
				    when 'unit'		then drawing.unit = value.to_sym
				    when 'unitdist'	then drawing.unitdistance = value.to_sym
				    when 'multiple'	then drawing.multiple = value.to_i
				    when 'style'	then drawing.style = value.to_sym
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

	# Generate XML for the {Drawing} element
	# @return [REXML::element]
	def to_xml
	    drawing_element = REXML::Element.new 'drawing'

	    settings = REXML::Element.new 'settings', drawing_element
	    settings.add_element 'setting', {'alwaysvectorfont' => (always_vector_font ? 'yes' : 'no')}
	    settings.add_element 'setting', {'verticaltext' => vertical_text}

	    grid_element = REXML::Element.new 'grid', drawing_element
	    grid_element.add_attributes({   'altdistance'   => altdistance,
					    'altunit'	    => altunit,
					    'altunitdist'   => altunitdist,
					    'display'	    => (display ? 'yes' : 'no'),
					    'distance'	    => distance,
					    'multiple'	    => multiple,
					    'unit'	    => unit,
					    'unitdist'	    => unitdistance,
					    'style'	    => style,
					 })

	    layers_element = REXML::Element.new 'layers', drawing_element
	    layers.each {|layer| layers_element.add_element layer.to_xml }

	    drawing_element.add_element(board.to_xml) if board
	    drawing_element.add_element(schematic.to_xml) if schematic

	    drawing_element
	end

	# @param filename [String] The path to write the output to
	def write(output)
	    document = REXML::Document.new('<?xml version="1.0" encoding="utf-8"?><!DOCTYPE eagle SYSTEM "eagle.dtd">')

	    eagle = REXML::Element.new('eagle')
	    eagle.add_attribute('version', '6.0')
	    eagle.add_element to_xml
	    document.add eagle

	    output = File.open(output, 'w') if output.is_a? String

	    # This is a hack to force REXML to output PCDATA text inline with the enclosing element. Eagle has problems with the extra newlines that REXML tends to add.
	    formatter = REXML::Formatters::Pretty.new(0)
	    formatter.compact = true
	    formatter.write(document, output)

	    output.close
	end
    end
end
