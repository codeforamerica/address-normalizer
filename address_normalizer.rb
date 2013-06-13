require 'csv'
require 'street_address'
require 'cmess/guess_encoding'
require 'pry'

class AddressNormalizer

  attr_reader :errors, :malformed_rows

  def initialize(filename)
    @errors         = []
    @malformed_rows = []
    @normalized_address_index = 0
    @timestamp = Time.now.to_s.gsub(/:|-/,"").gsub(/\s+/,"_")
    @address_index = 0

    normalize_csv(filename)
  end

  # Given a CSV file, creates a new one with normalized addresses
  # If there are malformed rows/errors, saves those to a separate output file
  def normalize_csv(filename)
    # Check encoding
    source_encoding = get_encoding(filename)

    # normalize_file
    process_csv(filename, source_encoding)

    # If there were problem rows, print them to the user and save them to a file
    handle_malformed_rows unless @malformed_rows.empty?

    puts "Done!"
  end

  def get_encoding filename
    puts "Opening file to check encoding..."

    source_file     = File.read(filename)
    source_encoding = CMess::GuessEncoding::Automatic.guess(source_file)

    puts "Encoding: #{source_encoding}"
    puts "Total number of rows: #{source_file.lines.count}"

    source_file = nil

    return source_encoding
  end

  #TODO-mike break this up
  def process_csv(filename, source_encoding)
    puts "Normalizing addresses (this may take a while)..."

    normalized_out = File.open("#{File.basename(filename,".*")}_NormalizedAddresses_#{@timestamp}.csv", "w")

    counter = 0
    IO.foreach(filename, :encoding => source_encoding) do |line|
      puts "On row #{counter}" if counter % 100 == 0
      # If the header row, get the indecx for the address and add a column for the address_normalized
      if counter == 0
        handle_first_row(normalized_out, line)
        # For normal rows, normalize, write to file, and catch errors
      else
        normalize_line(normalized_out, line)
      end
      counter += 1
    end
    #not closing screws up tests
    normalized_out.close
  end

  def handle_first_row(file, line)
    CSV.parse(line) do |row|
      # check if 'address' exists
      @address_index = row.index("address")
      row << "address_normalized"
      @normalized_address_index = row.index("address_normalized")
      file.write(CSV.generate_line(row))
    end
  end

  def normalize_line(file, line)
    begin
      CSV.parse(line) do |row|
        begin
          strt_ad = StreetAddress::US.parse(row[@address_index] + ", , ")
          # Catch empty address
        rescue NoMethodError
          strt_ad = ""
        end
        row << strt_ad.to_s.upcase
        file.write(CSV.generate_line(row))
      end
      # Rescue from problem rows
    rescue CSV::MalformedCSVError => er
      @errors << er.message
      @malformed_rows << line
    end
  end

  def handle_malformed_rows
    puts "Errors: #{@errors.to_s}\n\n\n" unless @errors.empty?

    malformed_row_output_file = File.open("AddressNormalizer_MalformedRows_#{@timestamp}.txt", "w")
    puts "Malformed rows:"
    @malformed_rows.each do |row|
      puts row
      malformed_row_output_file.write(row + "\n")
    end
    puts "Malformed rows saved to disk in #{malformed_row_output_file.path}."
    
    malformed_row_output_file.close
  end

end
