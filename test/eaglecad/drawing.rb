require 'minitest/autorun'
require 'eaglecad/drawing'

describe EagleCAD::Drawing do
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

	describe "when generating XML" do
	    let(:element) { subject.to_xml }

	    it "must generate a proper XML element" do
		element.must_be_instance_of REXML::Element
	    end

	    it "must have a settings element" do
		element.get_elements('settings').count.must_equal 1
		element.get_elements('settings').first.must_be_instance_of(REXML::Element)
	    end

	    it "must have a grid element" do
		element.get_elements('grid').count.must_equal 1
	    end

	    it "must have a layers container element" do
		element.get_elements('layers').count.must_equal 1
	    end

	    it "must have the correct number of layers" do
		element.get_elements('layers').first.get_elements('layer').count.must_equal 43
	    end

	    it "must have a Board" do
		element.elements['board'].wont_be_nil
	    end
	end
    end

    describe "when the Drawing has only a Schematic" do
	subject { EagleCAD::Drawing.from_xml(REXML::Document.new(File.open('test/fixtures/drawing_schematic.xml')).elements.first) }

	describe "when generating XML" do
	    let(:element) { subject.to_xml }

	    it "must generate a proper XML element" do
		element.must_be_instance_of REXML::Element
	    end

	    it "must have a settings element" do
		element.get_elements('settings').count.must_equal 1
		element.get_elements('settings').first.must_be_instance_of(REXML::Element)
	    end

	    it "must have a grid element" do
		element.get_elements('grid').count.must_equal 1
	    end

	    it "must have a layers container element" do
		element.get_elements('layers').count.must_equal 1
	    end

	    it "must have the correct number of layers" do
		element.get_elements('layers').first.get_elements('layer').count.must_equal 59
	    end

	    it "must have a Schematic" do
		element.get_elements('schematic').count.must_equal 1
	    end
	end
    end
end
