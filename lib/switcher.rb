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
  class Ethernet
    include Capybara::DSL
    include Networker

    def initialize
      @session = Capybara::Session.new(:selenium)
    end

    def get_wifi_password area
      continue = connect($settings[:wired_network_name])
      LOGGER.info("Connected to network \"#{$settings[:wired_network_name]}\"") if continue
      LOGGER.error("Cannot connect to network \"#{$settings[:wired_network_name]}\"") unless continue

      wifi_password = get_wifi_password_with($settings[:sso_name], Base64.decode64($settings[:sso_passwd]), area) if continue
      if wifi_password
        File.open('.pswd', 'w') { |file| file.write(wifi_password) }
        LOGGER.info("Password of clear-guest is : #{wifi_password}") if wifi_password
      else
        LOGGER.info("Quit")
      end

      wifi_password
    end

    private
    def get_wifi_password_with sso_name, sso_passwd, area
      @session.visit "https://gmp.oracle.com/captcha/"
      LOGGER.info("Accessing https://gmp.oracle.com/captcha/ to get today's wifi password")

      #fill SSO password to access WIFI Password Page
      @session.fill_in 'sso_username', :with => sso_name
      @session.fill_in 'ssopassword', :with => sso_passwd
      @session.find(:xpath, "//a[@class='submit_btn']").click
      LOGGER.info("Filling in SSO login to access the real page")

      #click button to get WIFI password
      password = nil
      begin
        password = get_wifi_password_by(area, @session)
      rescue Exception => e
        LOGGER.info("Incorrect SSO Login : wrong user name or password #{e.message}")
      end
      @session.driver.browser.close

      password
    end

    def get_wifi_password_by area, session
      LOGGER.info("Unpacking clear-guest password for #{area}")
      @session.find(:xpath, "//button[@id='#{$locations[area.to_sym]}']").click
      text = @session.find(:xpath, "//span[@id='ext-gen38']/pre").text
      /.*Password: (.*)(Generated.*)?/.match(text)[1].split[0]
    end
  end

  class QRGenerator
    include Capybara::DSL
    include Networker
    include Mailer

    def initialize
      @session = Capybara::Session.new(:selenium)
    end

    def send_qr_code_email_with password, time_zone
      #continue = disconnect_from_ethernet
      #continue = connect($settings[:wireless_network_name]) if continue
      send_mail_with($settings[:sso_name], password, time_zone)# if continue
    end

    private
    def send_mail_with sso_name, password, time_zone
      subject = "Password of WIFI network clear-guest - #{Time.now.strftime("%m/%d/%Y")}"

      LOGGER.info("Sending email which contains QR code to #{sso_name}")
      Mailer.send_mail(sso_name, subject, password, time_zone)
      LOGGER.info("Sent")
    end
  end
end

area = ARGV[0]
time_zone = ARGV[1]
wifi_passwd = NetworkSwitcher::Ethernet.new.get_wifi_password(area)
NetworkSwitcher::QRGenerator.new.send_qr_code_email_with(wifi_passwd, time_zone) if wifi_passwd
