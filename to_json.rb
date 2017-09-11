require 'csv'
require 'json'

file = 'data2.csv'
# TODO: Check file encoding - some destinations airports are missing a few chars.
file_contents = CSV.read(file, col_sep: ",", encoding: "ISO8859-1")
grouped_hash = file_contents[1..-1].group_by { |x| x[0] }

master_arr = []
id_iterator = 1

grouped_hash.each do |name, arr|
  name = { id: id_iterator, name: name, totalBookings: arr.count, topBookings: { } }

  arr.each do |record|
    destination_airport = record[3]
    
    if name[:topBookings][destination_airport]
      name[:topBookings][destination_airport] += 1
    else
      name[:topBookings][destination_airport] = 1
    end
  end

  top_bookings_array = []
  name[:topBookings].each do |destination, count|
    top_bookings_array << { name: destination, count: count }
  end

  # Sort by the top bookings count and take the top 6 only
  name[:topBookings] = top_bookings_array.sort_by { |k| k[:count] }.reverse.take(6)

  master_arr << name
  id_iterator += 1
end

# Output a few samples into the terminal (for reference)
5.times do
  puts JSON.pretty_generate(master_arr.sample)
  puts "-" * 90
end

# Sanity check - file_contents.size == count of total bookings?
puts file_contents[1..-1].size
puts master_arr.map {|s| s[:totalBookings]}.reduce(0, :+)

final_output = [] << { total: master_arr.count, names: master_arr };nil

# puts JSON.pretty_generate(final_output)

File.open("data3.json", "w") do |f|
  f.write(JSON.pretty_generate(final_output))
end