require 'minitest/autorun'
require 'eaglecad'

describe EagleCAD do
    describe "when reading a schematic file" do
	subject { EagleCAD.read('test/fixtures/demo1.sch') }

	it "must return a Drawing object" do
	    subject.must_be_kind_of(EagleCAD::Drawing)
	end
    end
end
