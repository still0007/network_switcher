require 'capybara'
require 'capybara/dsl'
require 'base64'
require 'net/smtp'
require 'erb'
require 'rbconfig'
require_relative "initializer"
require_relative "mail/send_mail"
require_relative "networker/#{RbConfig::CONFIG['target_os']}"

$settings = Setting.first
unless $settings
  puts "Error: You haven't setup your networker switcher!"
  puts "Type \"ruby setup.rb\" to launch the setup wizard."
  exit
end

module NetworkSwitcher
  class WIFIClearGuest
    include Capybara::DSL
    include Networker

    def initialize
      @session = Capybara::Session.new(:selenium)
    end

    def authenticate_with password
      continue = disconnect_from_ethernet
      continue = connect($settings[:wireless_network_name]) if continue
      LOGGER.info("Connected to network \"#{$settings[:wireless_network_name]}\"") if continue
      LOGGER.error("Cannot connect to network \"#{$settings[:wireless_network_name]}\"") unless continue

      authenticate_wireless_network(password) if continue
    end

    private
    def authenticate_wireless_network password
      @session.visit "http://www.google.com"
      LOGGER.info("Accessing random URL to let browser redirect to web authentication page")

      #fill wifi password to authenticate wireless network
      if @session.title == "Web Authentication Redirect"
        @session.fill_in 'username', :with => 'guest'
        @session.fill_in 'password', :with => password
        @session.find(:xpath, "//input[@name='Submit']").click
        LOGGER.info("Fill in password(#{password}) to authenticate")
      else
        LOGGER.info("You've already authenticated")
      end

      @session.driver.browser.close
    end
  end
end

wifi_passwd = nil
File.open(".pswd", "r") { |io|  wifi_passwd = io.gets }
NetworkSwitcher::WIFIClearGuest.new.authenticate_with wifi_passwd if wifi_passwd
