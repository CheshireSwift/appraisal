require 'net/http'
require 'uri'
require 'json'
require 'rack'

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

  def Price.none
    Price.new(0, 0)
  end
end

def get(path, query_hash = {})
  query_string = query_hash.length > 0 ? '?' + Rack::Utils.build_query(query_hash) : ''
  uri = URI::join(BASE_URI, path) + query_string
  response = Net::HTTP.get_response(uri)
  JSON.parse(response.body)
end

def get_mats_value(api_key)
  bank_slots = get(
    'account/materials',
    {:access_token => api_key}
  ).select { |bank_slot| bank_slot['count'] > 0 }
  
  bank_slots.each_with_index.map do |bank_slot, i|
    STDOUT.write "#{i}/#{bank_slots.length} (#{(i.fdiv(bank_slots.length) * 100).round}%)\r"
    get_value(bank_slot['id']) * bank_slot['count']
  end
end

def get_value(item_id)
  if !item_id then
    puts "Missing entry."
    return Price.none
  end

  results = get("commerce/prices/#{item_id}")
  #puts results
  results['id'] ? Price.new(results["buys"]["unit_price"], results["sells"]["unit_price"]) : Price.none
end

def pretty_print(total_copper)
  copper = total_copper % 100
  silver = (total_copper / 100) % 100
  gold = total_copper / (100 * 100)
  "#{gold}g #{silver}s #{copper}c"
end
