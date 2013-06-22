require 'test/unit'
require 'csv'
require_relative 'address_normalizer'

class FileNormalizerTest < Test::Unit::TestCase

	# run and create test1_NormalizedAddresses_<time>.csv
	def setup
		@timestamp = Time.now.to_s.gsub(/:|-/,"").gsub(/\s+/,"_")
		@filename  = "test1_NormalizedAddresses_#{@timestamp}.csv"
		@malformed = "AddressNormalizer_MalformedRows_#{@timestamp}.txt"

		@normalized = AddressNormalizer.new('example_data/test1.csv')
	end

	# main test function
	def test_normalized_file_exist
		assert File.exists?(@filename), 'Normalized file was not created'
	end

	# assert that 'address_normalized' column was added
	def test_first_row_has_normalized_column
		rows = CSV.read(@filename)
		assert rows[0].include?('address_normalized')
	end

	# dumb check for properly normalized column
	def test_normalized_address_created
		rows = CSV.read(@filename)
		assert rows[1][2] == "6687 DEL PARTY AVENUE 90045, ISLA VISTA, CA"
	end

	def test_unclosed_row_error_caught
		assert !@normalized.errors.empty?
	end

	def test_malformed_rows_file_existance
		assert File.exists?(@malformed), 'Malformed file was not created'
	end


	def teardown
		File.delete(@filename)
		File.delete(@malformed)
	end

end