require 'minitest/autorun'
require 'eaglecad/library'

describe EagleCAD::Library do
    subject { EagleCAD::Library.from_xml(REXML::Document.new(File.open('test/fixtures/library.xml')).elements.first) }

    it "must have a name" do
	subject.name.must_equal 'microchip'
    end

    it "must not have a description" do
	subject.description.must_be_nil
    end

    it "must have the correct number of device sets" do
	subject.device_sets.size.must_equal 1
    end

    it "must have the correct number of packages" do
	subject.packages.size.must_equal 2
    end

    it "must have the correct number of symbols" do
	subject.symbols.size.must_equal 1
    end

    describe "when generating XML" do
	subject { EagleCAD::Library.from_xml(REXML::Document.new(File.open('test/fixtures/library.xml')).elements.first).to_xml }

	it "must generate an XML element" do
	    subject.must_be_instance_of REXML::Element
	end

	it "must have a Device Sets container element" do
	    subject.get_elements('devicesets').count.must_equal 1
	    subject.elements['devicesets'].wont_be_nil
	end

	it "must have a Packages container element" do
	    subject.get_elements('packages').count.must_equal 1
	end

	it "must have a Symbols container element" do
	    subject.get_elements('symbols').count.must_equal 1
	end
    end
end
