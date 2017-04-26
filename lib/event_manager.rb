require "csv"
require "sunlight/congress"
require "erb"

def clean_zipcode zipcode
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode zipcode
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_yous id, form_letter
  Dir.mkdir("output") unless Dir.exists? "output"

  file_name = "output/thanks_#{id}.html"

  File.open(file_name, "w") { |file| file.puts form_letter }
end

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

puts "Event Manager".upcase

template_letter = File.read("form_letter.erb")
erb_template = ERB.new template_letter

data = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

data.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode row[:zipcode]
  legislators = legislators_by_zipcode zipcode

  form_letter = erb_template.result binding

  save_thank_yous id, form_letter
end