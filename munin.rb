require "./lib/cli"
require "./lib/payload"
require "./lib/connection"
require "./lib/crc8"


cli = BTWATTCH2::CLI.new
if cli.addr.nil?
  cli.help
  exit
end

conn = BTWATTCH2::Connection.new(cli)
conn.subscribe_measure! do |e|
  puts "voltage\t#{e[:voltage]}"
  puts "ampere\t#{e[:ampere]}"
  puts "wattage\t#{e[:wattage]}"

  exit
end
