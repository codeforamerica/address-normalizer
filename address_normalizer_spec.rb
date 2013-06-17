require 'csv'
require_relative 'address_normalizer'

describe AddressNormalizer do

	before :all do
		@timestamp = Time.now.to_s.gsub(/:|-/,"").gsub(/\s+/,"_")
		@filename  = "test1_NormalizedAddresses_#{@timestamp}.csv"
		@malformed = "AddressNormalizer_MalformedRows_#{@timestamp}.txt"

		@normalized = AddressNormalizer.new('example_data/test1.csv')
	end

	it "should create a normalized output file" do
		File.exists?(@filename).should be_true
	end	

	it "should add an 'address_normalized' column" do
		rows = CSV.read(@filename)
		rows[0].should include('address_normalized')
	end

	it "should create a properly normalized address" do
		rows = CSV.read(@filename)
		rows[1][2].should == "6687 DEL PARTY AVENUE 90045, ISLA VISTA, CA"
	end

  # todo - write a better test (regex?)
	it "should catch unclosed row errors" do
	  @normalized.errors.should include("Illegal quoting in line 1.")
	end	

	it "should create file of malformed rows" do
    File.exists?(@malformed).should be_true
	end

	after :all do
		File.delete(@filename)
		File.delete(@malformed)
	end

end