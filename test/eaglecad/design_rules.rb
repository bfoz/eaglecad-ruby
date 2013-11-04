require 'minitest/autorun'
require 'eaglecad/design_rules'

describe EagleCAD::DesignRules do
    subject { EagleCAD::DesignRules.from_xml(REXML::Document.new(File.open('test/fixtures/design_rules.xml')).elements.first) }

    it "must have a name" do
	subject.name.must_equal 'Name'
    end

    it "must have a description" do
	subject.description.must_equal 'Design Rule Description'
    end

    it "must have the correct number of parameters" do
	subject.parameters.size.must_equal 67
    end

    describe "when generating XML" do
	let(:element) { subject.to_xml }

	it "must generate a proper XML element" do
	    element.must_be_instance_of REXML::Element
	end

	it "must have a name attribute" do
	    element.attributes['name'].must_equal 'Name'
	end

	it "must have a description element" do
	    element.elements['description'].text.must_equal 'Design Rule Description'
	end

	it "must have parameter elements" do
	    element.get_elements('param').count.must_equal 67
	end
    end
end
