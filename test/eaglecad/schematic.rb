require 'minitest/autorun'
require 'eaglecad/schematic'

describe EagleCAD::Schematic do
    describe "when initialized with an XML element" do
	subject { EagleCAD::Schematic.from_xml(REXML::Document.new(File.open('test/fixtures/schematic.xml')).elements.first) }

	it "must have a description" do
	    subject.description.must_equal 'Schematic Description'
	end

	it "must have the correct number of attributes" do
	    subject.attributes.count.must_equal 0
	end

	it "must have the correct number of clearance classes" do
	    subject.classes.size.must_equal 2
	end

	it "must have the correct number of libraries" do
	    subject.libraries.count.must_equal 8
	end

	it "must have the correct number of parts" do
	    subject.parts.size.must_equal 27
	end

	it "must have the correct number of sheets" do
	    subject.sheets.size.must_equal 1
	end
    end
end
