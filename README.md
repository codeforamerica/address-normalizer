# Address Normalizer

A simple tool that takes a CSV with an "address" column and adds a column with normalized addresses, using [the Ruby street_address gem](https://github.com/derrek/street-address) (a port of the Perl module [Geo::StreetAddress::US](http://search.cpan.org/~sderle/Geo-StreetAddress-US-0.99/)).

Command-Line Usage:

    ruby normalize_csv_addresses.rb "my_file_with_addresses.csv"

