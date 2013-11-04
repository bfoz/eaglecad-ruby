require 'rexml/document'

module EagleCAD
    class DesignRules
	attr_accessor :description, :name
	attr_reader :parameters

	def self.from_xml(element)
	    self.new(element.attributes['name']).tap do |rule|
		element.elements.each do |element|
		    case element.name
			when 'description'
			    rule.description = element.text
			when 'param'
			    rule.parameters[element.attributes['name']] = element.attributes['value']
			else
			    raise StandardError, "Unrecognized Design Rule element '#{element.name}'"
		    end
		end
	    end
	end

	def initialize(name)
	    @name = name
	    @parameters = {}
	end

	# @return [REXML::Element]
	def to_xml
	    REXML::Element.new('designrules').tap do |element|
		element.add_attribute 'name', name
		element.add_element('description').text = description if description

		parameters.each {|key, value| element.add_element('param', {'name' => key, 'value' => value})}
	    end
	end
    end
end
