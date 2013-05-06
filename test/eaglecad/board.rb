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
    end
end
