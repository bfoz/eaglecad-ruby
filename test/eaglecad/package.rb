require 'minitest/autorun'
require 'eaglecad/package'

describe EagleCAD::Package do
    Package = EagleCAD::Package

    describe "when initialized with an XML element" do
	subject { Package.from_xml(REXML::Document.new(File.open('test/fixtures/package.xml')).elements.first) }

	it "must have a name" do
	    subject.name.must_equal 'C0402'
	end

	it "must have a description" do
	    subject.description.must_equal '<b>CAPACITOR</b><p>chip'
	end

	it "must have the correct number of layers" do
	    subject.layers.size.must_equal 7
	end

	it "must have the correct layers" do
	    subject.layers[1].size.must_equal 2
	    subject.layers[21].size.must_equal 1
	    subject.layers[25].size.must_equal 1
	    subject.layers[27].size.must_equal 1
	    subject.layers[35].size.must_equal 1
	    subject.layers[39].size.must_equal 4
	    subject.layers[51].size.must_equal 5
	end

	it "must have the correct holes" do
	    subject.holes.size.must_equal 1
	end

	it "must have the correct pads" do
	    subject.pads.size.must_equal 1
	end
    end
end
