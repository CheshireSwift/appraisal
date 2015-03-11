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
    "#{self.low} - #{self.high}"
  end

end

def get(path)
  uri = URI::join(BASE_URI, path)
  response = Net::HTTP.get_response(uri)
  JSON.parse(response.body)
end

def get_value(item_id)
  results = get("commerce/prices/#{item_id}")
  Price.new(results["buys"]["unit_price"], results["sells"]["unit_price"])
end

