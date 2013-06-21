require "easypost"

EasyPost.api_key = "cueqNZUb3ldeWTNX7MU3Mel8UXtaAMUi"
p EasyPost::Address.verify({
  street1: "101 California St",
  street2: "Suite 1290",
  city: "San Francisco",
  state: "CA",
  zip: "94111"
  })