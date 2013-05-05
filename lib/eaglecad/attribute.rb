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
			when 'display'	then attribute.display = value.to_sym
			when 'font'	then attribute.font = value.to_sym
		    end
		end
	    end
	end

	def initialize
	    super
	    @display = :value
	end
    end
end
