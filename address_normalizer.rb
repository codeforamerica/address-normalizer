require 'csv'
require 'street_address'
require 'cmess/guess_encoding'
require 'pry'

module AddressNormalizer

  # Given a CSV file, creates a new one with normalized addresses
  # If there are malformed rows/errors, saves those to a separate output file
  def self.normalize_csv(filename)

    # Overhead setup
    counter       = 0
    address_index = 0
    normalized_address_index = 0

    errors         = Array.new
    malformed_rows = Array.new
    timestamp      = Time.now.to_s.gsub(/:|-/,"").gsub(/\s+/,"_")

    normalized_output_file = File.open("#{File.basename(filename,".*")}_NormalizedAddresses_#{timestamp}.csv", "w")

    # Check encoding
    source_encoding = check_encoding(filename)

    puts "Normalizing addresses (this may take a while)..."

    IO.foreach(filename, :encoding => source_encoding) do |line|
      puts "On row #{counter}" if counter % 100 == 0

      # If the header row, get the index for the address and add a column for the address_normalized
      if counter == 0
        CSV.parse(line) do |row|
          address_index = row.index("address")
          row << "address_normalized"
          normalized_address_index = row.index("address_normalized")
          normalized_output_file.write(CSV.generate_line(row))
        end
        counter += 1

      # For normal rows, normalize, write to file, and catch errors
      else
        begin
          CSV.parse(line) do |row|
            begin
              sa = StreetAddress::US.parse(row[address_index] + ", , ")
            # Catch empty address
            rescue NoMethodError
              sa = ""
            end
            row << sa.to_s.upcase
            normalized_output_file.write(CSV.generate_line(row))
            counter = counter + 1
          end
        # Rescue from problem rows
        rescue CSV::MalformedCSVError => er
          errors << er.message
          malformed_rows << line
        end
      end

    end

    # If there were problem rows, print them to the user and save them to a file
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

  def self.check_encoding filename
    puts "Opening file to check encoding..."
    
    source_file     = File.read(filename)
    source_encoding = CMess::GuessEncoding::Automatic.guess(source_file)
    
    puts "Encoding: #{source_encoding}"
    puts "Total number of rows: #{source_file.lines.count}"
    
    source_file = nil

    return source_encoding
  end

end
