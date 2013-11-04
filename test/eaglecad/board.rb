require 'minitest/autorun'
require 'eaglecad/board'

describe EagleCAD::Board do
    describe "when initialized with an XML element" do
	subject { EagleCAD::Board.from_xml(REXML::Document.new(File.open('test/fixtures/board.xml')).elements.first) }

	it "must have a description" do
	    subject.description.must_equal 'Board Description'
	end

	it "must have the correct number of libraries" do
	    subject.libraries.size.must_equal 6
	end

	it "must have the correct number of elements" do
	    subject.elements.size.must_equal 12
	end

	describe "when generating XML" do
	    let(:element) { subject.to_xml }

	    it "must generate a proper XML element" do
		element.must_be_instance_of REXML::Element
	    end
	end

	describe "when generating XML" do
	    let(:element) { subject.to_xml }

	    it "must generate a proper XML element" do
		element.must_be_instance_of REXML::Element
	    end

	    it "must have a description" do
		element.elements['description'].text.must_equal 'Board Description'
	    end

	    it "must have an attributes container" do
		element.elements['attributes'].count.must_equal 0
	    end

	    it "must have an autorouter container" do
		element.elements['autorouter'].count.must_equal 4
	    end

	    it "must have a classes container" do
		element.elements['classes'].count.must_equal 2
	    end

	    it "must have a designrules container" do
		element.elements['designrules'].count.must_equal 68
	    end

	    it "must have an elements container" do
		element.elements['elements'].count.must_equal 12
	    end

	    it "must have a libraries container" do
		element.elements['libraries'].count.must_equal 6
	    end

	    it "must have a plan container" do
		element.elements['plain'].count.must_equal 4
	    end
	end
    end
end
