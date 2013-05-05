require 'minitest/autorun'
require 'eaglecad/deviceset'

describe EagleCAD::DeviceSet do
    subject { EagleCAD::DeviceSet.from_xml(REXML::Document.new(File.open('test/fixtures/deviceset.xml')).elements.first) }

    it "must have a name" do
	subject.name.must_equal 'C-EU'
    end

    it "must have a prefix" do
	subject.prefix.must_equal 'C'
    end

    it "must have a uservalue" do
	subject.uservalue.must_equal true
    end

    it "must have a description" do
	subject.description.must_equal '<B>CAPACITOR</B>, European symbol'
    end

    it "must have the correct number of devices" do
	subject.devices.size.must_equal 75
    end

    it "must have the correct number of gates" do
	subject.gates.size.must_equal 1
	subject.gates.first.name.must_equal 'G$1'
    end
end
