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


    describe "when generating XML" do
	subject { EagleCAD::Symbol.from_xml(REXML::Document.new(File.open('test/fixtures/symbol.xml')).elements.first).to_xml }

	it "must generate an XML element" do
	    subject.must_be_instance_of REXML::Element
	end

	it "must have the correct name attribute" do
	    subject.attributes['name'].must_equal 'C-EU'
	end

	it "must have a description element" do
	    subject.elements['description'].text.must_equal 'A Description'
	end

	it "must have the correct number of children" do
	    subject.elements.count.must_equal 9
	end
    end
end
