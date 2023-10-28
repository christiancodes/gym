require 'net/http'
require 'json'

scrape_success = false

begin
  uri = URI("https://portal.rockgympro.com/portal/public/da1bdc14b9e219e81de152ec2576d858/occupancy?&iframeid=occupancyCounter&fId=1347")
  req = Net::HTTP::Get.new(uri)
  response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http|
    http.request(req)
  }
  scrape_success = true
rescue => e
  puts "Unexpected error during scrape: #{e.message}"
end

if scrape_success
  cleaned_data = response.body.split('var data = ')[1].split(';')[0]
  cleaned_data = cleaned_data.gsub("'", '"')
                             .gsub("\n", '')
                             .gsub(" ", '')
                             .gsub(":&nbsp", ' ')
                             .gsub("},}", '}}')
  json = JSON.parse(cleaned_data)

  puts "Gottingen:   #{json['SBG']['count']} / #{json['SBG']['capacity']}"
  puts "Bayers Lake: #{json['SBL']['count']} / #{json['SBL']['capacity']}"

else
  puts "Error getting gym numbers!"
end
