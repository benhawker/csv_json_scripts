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


final_output = [] << { total: master_arr.count, names: master_arr };nil

CSV.open("output_csv.csv", "w") do |csv|
  csv << ["ID", "NAME", "TOTAL BOOKINGS", "1", "1 COUNT", "2", "2 COUNT", "3", "3 COUNT", "4", "4 COUNT", "5", "5 COUNT", "6", "6 COUNT"]
  master_arr.map do |record|
    csv << record.values.map do |value|
      if value.is_a?(Array)
        value.map do |x|
          x.values.flatten
        end
      else
        value
      end
    end.flatten
  end
end