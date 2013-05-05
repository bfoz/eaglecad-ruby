require 'minitest/autorun'
require 'eaglecad/sheet'

describe EagleCAD::Sheet do
    describe "when initialized with an XML element" do
	subject { EagleCAD::Sheet.from_xml(REXML::Document.new(File.open('test/fixtures/sheet.xml')).elements.first) }

	it "must have a description" do
	    subject.description.must_equal 'Sheet Description'
	end

	it "must have the correct number of busses" do
	    subject.busses.size.must_equal 1
	end

	it "must have the correct number of instances" do
	    subject.instances.size.must_equal 28
	end

	it "must have the correct number of nets" do
	    subject.nets.size.must_equal 21
	end
    end
end
