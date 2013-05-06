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
    end
end
