require 'test/unit'
require 'csv'
require_relative 'address_normalizer'

class AddressNormalizerTest < Test::Unit::TestCase

	# run and create test1_NormalizedAddresses_<time>.csv
	def setup
		@timestamp = Time.now.to_s.gsub(/:|-/,"").gsub(/\s+/,"_")
		@filename  = "test1_NormalizedAddresses_#{@timestamp}.csv"
		@malformed = "AddressNormalizer_MalformedRows_#{@timestamp}.txt"

		@normalized = AddressNormalizer.new('example_data/test1.csv')
	end

	# main test function
	def test_NormalizedFileExists
		assert File.exists?(@filename), 'Normalized file was not created'
	end

	# assert that 'address_normalized' column was added
	def test_FirstRowHasNormalizedColumn
		rows = CSV.read(@filename)
		assert rows[0].include?('address_normalized')
	end

	# dumb check for properly normalized column
	def test_CrudeCheck
		rows = CSV.read(@filename)
		assert rows[1][2] == "6687 DEL PARTY AVENUE 90045, ISLA VISTA, CA"
	end

	# TODO malformed rows test
	def test_unclosedRowError
		assert !@normalized.errors.empty?
		puts @timestamp
	end

	def test_MalformedRowsFileExists
		assert File.exists?(@malformed), 'Malformed file was not created'
	end


	def teardown
		File.delete(@filename)
		File.delete(@malformed)
	end

end