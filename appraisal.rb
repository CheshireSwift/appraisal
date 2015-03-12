require_relative 'helpers'

class ItemRow
  attr_accessor :name
  attr_accessor :count

  def initialize(line)
    raw_name, raw_count = line.chomp.split(',')
    @name, @count = raw_name, raw_count.to_i
  end

  def to_s
    "#{count}x #name"
  end
end

def array_to_hash(array)
  Hash[array.each_slice(2).to_a]
end

item_list = File.open(ARGV[0])
ids_by_name = array_to_hash(item_list.map { |line| line.chomp.split(',') }.flatten)
#puts ids_by_name
bank_list = File.open(ARGV[1])
prices = bank_list.map do |line| 
  row = ItemRow.new(line)
  id = ids_by_name[row.name]
  if !id then
    puts "No ID for name '#{row.name}'."
    Price.new(0, 0)
  else
    get_value(id) * row.count
  end
end
puts prices.inject(:+)
