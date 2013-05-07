require 'minitest/autorun'
require 'eaglecad/drawing'

describe EagleCAD::Drawing do
    subject { EagleCAD::Drawing.new }

    describe "when initialized with an XML element containing a Schematic" do
	subject { EagleCAD::Drawing.from_xml(REXML::Document.new(File.open('test/fixtures/drawing_schematic.xml')).elements.first) }

	it "must set the vector font property" do
	    subject.always_vector_font.must_equal true
	end

	it "must set the vertical text property" do
	    subject.vertical_text.must_equal :up
	end

	it "must have the correct number of layers" do
	    subject.layers.size.must_equal 59
	end

	it "must have a schematic" do
	    subject.schematic.must_be_instance_of(EagleCAD::Schematic)
	end
    end

    describe "when initialized with an XML element containing a Board" do
	subject { EagleCAD::Drawing.from_xml(REXML::Document.new(File.open('test/fixtures/drawing_board.xml')).elements.first) }

	it "must have a Board" do
	    subject.board.must_be_instance_of(EagleCAD::Board)
	end
    end
end
