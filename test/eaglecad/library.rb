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
end
