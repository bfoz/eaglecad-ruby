module EagleCAD
    class Layer
	attr_accessor :active, :color, :fill, :name, :number, :visible

	def self.from_xml(element)
	    self.new(element.attributes['name'], element.attributes['number'], element.attributes['color'], element.attributes['fill']).tap do |layer|
		element.attributes.each do |name, value|
		    case name
			when 'active'	then layer.active = ('no' != value)
			when 'visible'	then layer.active = ('no' != value)
		    end
		end
	    end
	end

	def initialize(name, number, color, fill)
	    @active = true
	    @color = color
	    @fill = fill
	    @name = name
	    @number = number
	    @visible = true
	end
    end
end