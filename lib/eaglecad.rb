require 'rexml/document'

require_relative 'eaglecad/drawing'

module EagleCAD
    # Load and parse the given {Schematic} or {Board} file
    # @return [Drawing]	A new {EagleCAD::Drawing}
    def self.read(filename)
	parse(REXML::Document.new File.open(filename))
    end

    # @param [REXML::Document]	An XML document to parse
    # @return [Drawing]	A new {EagleCAD::Drawing}, or nil if there was an error
    def self.parse(document)
	Drawing.from_xml(document.root.elements['drawing'])
    end
end
