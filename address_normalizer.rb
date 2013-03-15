require 'csv'
require 'street_address'

module AddressNormalizer

  # Given a CSV file, creates a new one with normalized addresses
  # If there are malformed rows/errors, saves those to a separate output file
  def self.normalize_csv(filename)
    counter = 0
    address_index = 0
    normalized_address_index = 0
    errors = Array.new
    malformed_rows = Array.new
    timestamp = Time.now.to_s.gsub(/:|-/,"")
    normalized_output_file = File.open("#{File.basename(filename,".*")}_NormalizedAddresses_#{timestamp}.csv", "w")
    IO.foreach(filename) do |line|
      # If the header row, get the index for the address and add a column for the address_normalized
      if counter == 0
        CSV.parse(line) do |row|
          address_index = row.index("address")
          row << "address_normalized"
          normalized_address_index = row.index("address_normalized")
          normalized_output_file.write(CSV.generate_line(row))
        end
        counter += 1
      else
        begin
          CSV.parse(line) do |row|
            sa = StreetAddress::US.parse(row[address_index] + ", , ")
            row << sa.to_s.upcase
            normalized_output_file.write(CSV.generate_line(row))
            counter = counter + 1
          end
        rescue CSV::MalformedCSVError => er
          errors << er.message
          malformed_rows << line
        end
      end
    end
    unless malformed_rows.empty?
      puts "Errors: #{errors.to_s}\n\n\n" unless errors.empty?
      malformed_row_output_file = File.open("AddressNormalizer_MalformedRows_#{timestamp}.txt", "w")
      puts "Malformed rows:"
      malformed_rows.each do |mr|
        puts mr
        malformed_row_output_file.write(mr)
        malformed_row_output_file.write("\n")
      end
      malformed_row_output_file.close
      puts "Malformed rows saved to disk in #{malformed_row_output_file.path}."
    end
    puts "Done!"
  end

end
