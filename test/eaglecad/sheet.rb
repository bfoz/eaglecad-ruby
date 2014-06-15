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

	it 'must connect nets to pins' do
	    subject.nets.first.connections.length.must_equal 18
	end
    end

    describe 'when generating XML' do
	subject { EagleCAD::Sheet.from_xml(REXML::Document.new(File.open('test/fixtures/sheet.xml')).elements.first).to_xml }

	it 'must generate an XML element' do
	    subject.must_be_instance_of REXML::Element
	end

	it 'must have a description element' do
	    subject.get_elements('description').length.must_equal 1
	    subject.get_elements('description').first.text.must_equal 'Sheet Description'
	end

	it 'must have a busses container element' do
	    subject.get_elements('busses').length.must_equal 1
	    subject.get_elements('busses').first.elements.size.must_equal 1
	end

	it 'must have an instances container element' do
	    subject.get_elements('instances').length.must_equal 1
	    subject.get_elements('instances').first.elements.size.must_equal 28
	end

	it 'must have a nets container element' do
	    subject.get_elements('nets').length.must_equal 1
	    subject.get_elements('nets').first.elements.size.must_equal 21
	end
    end
end
