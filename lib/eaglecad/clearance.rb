require 'rexml/document'

module EagleCAD
    class Clearance
	attr_accessor :name, :number, :width, :drill
	attr_reader :values

	def self.from_xml(element)
	    Clearance.new(element.attributes['name'], element.attributes['number'].to_i).tap do |clearance|
		clearance.width = (element.attributes['width'] || 0).to_f
		clearance.drill = (element.attributes['drill'] || 0).to_f

		element.elements.each {|element| clearance.values.push (element.text || 0).to_f }
	    end
	end

	def initialize(name, number)
	    @name = name
	    @number = number
	    @values = []
	end

	# @param [REXML::Element]
	def to_xml
	    REXML::Element.new('class').tap do |element|
		element.add_attributes({'name' => name, 'number' => number, 'width' => width, 'drill' => drill})
		values.each {|value| element.add_element('clearance', {'class' => number, 'value' => value})}
	    end
	end
    end
end
