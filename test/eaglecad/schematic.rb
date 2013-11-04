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

    describe "when generating XML" do
	subject { EagleCAD::Schematic.from_xml(REXML::Document.new(File.open('test/fixtures/schematic.xml')).elements.first).to_xml }

	it "must generate an XML element" do
	    subject.must_be_instance_of REXML::Element
	end

	it "must have a libraries container element" do
	    subject.get_elements('libraries').count.must_equal 1
	end

	it "must have the correct libraries" do
	    library_element = subject.get_elements('libraries').first.first
	    library_element.must_be_instance_of REXML::Element
	    library_element.attributes['name'].must_equal 'rcl'
	end
    end
end
