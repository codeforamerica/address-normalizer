require 'test/unit'
require 'csv'
require_relative 'address_normalizer'

class AddressNormalizerTest < Test::Unit::TestCase

	# run and create test1_NormalizedAddresses_<time>.csv
	def setup
		@timestamp = Time.now.to_s.gsub(/:|-/,"").gsub(/\s+/,"_")
		@filename  = "test1_NormalizedAddresses_#{@timestamp}.csv"

		AddressNormalizer.new('example_data/test1.csv')
	end

	# main test function
	def test_NormalizedFileExists
		assert File.exists?(@filename), 'Normalized file was not created'
		rows = CSV.read(@filename)
		puts "array: #{rows} #{@filename}"
		# assert rows[0].include?('address_normalized')
	end

	# assert that 'address_normalized' column was added
	# def test_FirstRowHasNormalizedColumn

	# end

	def teardown
		File.delete(@filename)
	end

end