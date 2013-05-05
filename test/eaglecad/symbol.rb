require 'minitest/autorun'
require 'eaglecad/symbol'

describe EagleCAD::Symbol do
    describe "when initialized from an XML element" do
	subject { EagleCAD::Symbol.from_xml(REXML::Document.new(File.open('test/fixtures/symbol.xml')).elements.first) }

	it "must have a name" do
	    subject.name.must_equal 'C-EU'
	end

	it "must have a description" do
	    subject.description.must_equal 'A Description'
	end

	it "must have the correct number of layers" do
	    subject.layers.size.must_equal 3
	end
    end
end
