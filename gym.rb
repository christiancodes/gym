require 'net/http'
require 'json'
require 'date'

scrape_success = false
closing_times = {
  0 => "9pm",
  1 => "11pm",
  2 => "11pm",
  3 => "11pm",
  4 => "11pm",
  5 => "11pm",
  6 => "9pm"
}
closes_at = closing_times[Date.today.wday]

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
                              .gsub("'", '"')
                              .gsub("\n", '')
                              .gsub(" ", '')
                              .gsub(":&nbsp", ' ')
                              .gsub("},}", '}}')
  json = JSON.parse(cleaned_data)

  puts "Gottingen:   #{json['SBG']['count']} / #{json['SBG']['capacity']}"
  puts "Bayers Lake: #{json['SBL']['count']} / #{json['SBL']['capacity']}"
  puts "Closes at: #{closes_at}"
else
  puts "Error getting gym numbers!"
end
