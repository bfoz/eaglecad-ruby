require_relative 'geometry'

module EagleCAD
    Attribute = Struct.new :name, :value, :origin, :size, :layer_number, :font, :ratio, :rotation, :display, :constant do
	def self.from_xml(element)
	    Attribute.new.tap do |attribute|
		attribute.name = element.attributes['name']
		attribute.value = element.attributes['value']
		attribute.origin = Geometry.point_from(element)
		attribute.size = element.attributes['size']
		attribute.layer_number = element.attributes['layer']
		attribute.ratio = element.attributes['ratio'].to_i
		attribute.rotation = element.attributes['rot']

		element.attributes.each do |name, value|
		    case name
			when 'constant'	then attribute.constant = ('yes' == element.attribute['constant'])
			when 'display'	then attribute.display = value
			when 'font'	then attribute.font = value
		    end
		end
	    end
	end

	def initialize
	    super
	    @display = 'value'
	end

	# @return [REXML::Element]
	def to_xml
	    REXML::Element.new('attribute').tap do |element|
		element.add_attribute('name', name)
		element.add_attribute('value', value)
		element.add_attribute('x', origin.x)
		element.add_attribute('y', origin.y)
		element.add_attribute('size', size)
		element.add_attribute('layer', layer_number)
		element.add_attribute('ratio', ratio) unless 0 == ratio
		element.add_attribute('rot', rotation)
		element.add_attribute('constant', 'yes') if constant
		element.add_attribute('display', display)
		element.add_attribute('font', font)
	    end
	end
    end
end
