require 'enumerator'

leave_words = %w{U.S.}
entries = {}
codes_in_order = []
open("countries.txt") do |f|
  f.readlines.each do |s|
    next if s[0] == ?#
    country, code = s.strip.split(";")
    code.downcase!
    country = country.split.map do |word|
      word.capitalize! unless leave_words.include? word
      word
    end.join(' ')
    if File.exists? "../public/images/fam3flags/#{code}.png"
      entries[code] = country
      codes_in_order << code
    else
      puts "Image not found for #{code}"
    end
  end
end

puts "country_codes = ["
codes_in_order.each_slice(10) do |tencountries|
  puts "  #{tencountries.map {|c| ":#{c}, " }}"
end
puts "]"
puts "code_to_country = {"
codes_in_order.each do |c|
  puts %Q_  :#{c} => "#{entries[c]}", _
end
puts "}"
