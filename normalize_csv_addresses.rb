require './address_normalizer'

if ARGV.empty?
  puts "Please provide the name of the CSV file with addresses to normalize. Example usage:"
  puts "ruby normalize_csv_addresses.rb \"my_addresses.csv\""
else
  AddressNormalizer.normalize_csv ARGV[0]
end
