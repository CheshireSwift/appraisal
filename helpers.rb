require 'net/http'
require 'uri'
require 'json'

BASE_URI = 'https://api.guildwars2.com/v2/'

class Price < Struct.new(:low, :high)

  def +(price)
    Price.new(self.low + price.low, self.high + price.high)
  end

  def *(num)
    Price.new(self.low * num, self.high * num)
  end

  def to_s
    "#{pretty_print self.low} - #{pretty_print self.high}"
  end

end

def get(path)
  uri = URI::join(BASE_URI, path)
  response = Net::HTTP.get_response(uri)
  JSON.parse(response.body)
end

def get_value(item_id)
  if !item_id then
    puts "Missing entry."
    return 0
  end

  results = get("commerce/prices/#{item_id}")
  #puts results
  Price.new(results["buys"]["unit_price"], results["sells"]["unit_price"])
end

def pretty_print(total_copper)
  copper = total_copper % 100
  silver = (total_copper / 100) % 100
  gold = total_copper / (100 * 100)
  "#{gold}g #{silver}s #{copper}c"
end
