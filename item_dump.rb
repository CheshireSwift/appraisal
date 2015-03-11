require_relative 'helpers'

item_map = {}
ids = get('items').first(10)
ids.each do |id|
  item = get("items/#{id}")
  item_map[item["name"]] = id
end

puts item_map.to_json
