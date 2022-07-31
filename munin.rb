#!/usr/bin/env ruby

require_relative "lib/cli"
require_relative "lib/payload"
require_relative "lib/connection"
require_relative "lib/crc8"

module BTW
  include BTWATTCH2
  SERVICE = BTWATTCH2::SERVICE
  C_TX = BTWATTCH2::C_TX
  C_RX = BTWATTCH2::C_RX

  class Con < Connection
    def initialize(cli)
      super(cli)

      @retry = 3
    end

    def write!(payload)
      @device.write(SERVICE, C_TX, payload)
    rescue DBus::Error => e
      if e.name == "org.bluez.Error.Failed"
        connect!
        @retry -= 1
        if @retry > 0
          retry
        else
          raise e
        end
      end
    rescue NoMethodError
      retry
    end
  end
end

cli = BTW::CLI.new
if cli.addr.nil?
  cli.help
  exit
end

conn = BTW::Con.new(cli)
begin
  conn.subscribe_measure! do |e|
    puts "voltage\t#{e[:voltage]}"
    puts "ampere\t#{e[:ampere]}"
    puts "wattage\t#{e[:wattage]}"

    exit
  end
rescue DBus::Error => e
  abort "[INFO] Failed to connect to #{cli.addr}"
end
