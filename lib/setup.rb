require 'base64'
require 'rbconfig'
require_relative "initializer"
require_relative "networker/#{RbConfig::CONFIG['target_os']}"

module NetworkSwitcher
  class SettingWizard
    include Networker

    def self.input(message, block)
      puts message
      while true do
        begin
          case block.call(gets.chomp)
            when 1
              break
            when 0, nil
              puts "Error: Invalid input"
            when -1
              exit
          end
        rescue Exception => e
          puts e
          puts "Error: Invalid input(#{e.message})"
          exit
        end
      end
    end

    def go
      if Setting.first != nil
        self.class.input(
          "You have already setup network switcher, continue(Y/n)?",
          Proc.new { | input | ((input && input.upcase == 'Y') || input.empty?)?1:-1 }
        )
      end

      record = {}
      record.merge!(setup_network())
      record.merge!(setup_sso())

      #store into DB
      Setting.dataset.delete
      Setting.insert(record)

      puts "Setup is complete!"
    end

    private
    def setup_network
      wired_network_name = ""
      wireless_network_name = ""
      location = ""

      puts "Available networks:"
      avail_networks = get_all_networks
      avail_networks.each_index { |index|
        puts "#{index+1} : #{avail_networks[index]}"
      }

      #setup Wired Network name
      self.class.input("Please select name of your Wired Network:?",
        Proc.new { | input |
          i = input.to_i
          if Range.new(1, avail_networks.length).include?(i)
            wired_network_name = avail_networks[i-1]
            1
          end
        }
      )

      #setup Wireless(clear-guest) Network name
      self.class.input(
        "Please select name of your Wireless(clear-guest) Network:",
        Proc.new { | input |
          i = input.to_i
          if Range.new(1, avail_networks.length).include?(i)
            wireless_network_name = avail_networks[i-1]
            1
          end
        }
      )

      puts "Available Locations:"
      $location_names = $locations.keys.sort!
      $location_names.each_with_index { |location, index|
        puts "#{index+1} : #{location}"
      }

      #setup your location
      self.class.input(
        "Please choose your location:",
        Proc.new { | input |
          i = input.to_i
          if Range.new(1, $location_names.length).include?(i)
            location = $location_names[i-1].to_s
            1
          end
        }
      )

      {:wired_network_name => wired_network_name,  :wireless_network_name => wireless_network_name, :location => location}
    end

    def setup_sso
      sso_name = ""
      sso_passwd = ""

      #setup SSO Login name
      self.class.input(
        "Please enter email address of your Oracle SSO login:",
        Proc.new { | input |
          if input
            sso_name = input
            1
          end
        }
      )

      #setup SSO Login password
      self.class.input(
        "Please enter password of your Oracle SSO login:\n!!!! Password of your Oracle SSO login is safe as it will be encrypted with Base64",
        Proc.new { | input |
          if input
            sso_passwd = Base64.encode64(input).chomp
            1
          end
        }
      )

      {:sso_name => sso_name,  :sso_passwd => sso_passwd}
    end
  end
end

NetworkSwitcher::SettingWizard.new.go
