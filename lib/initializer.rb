require 'sequel'
require 'logger'
require 'selenium-webdriver'

$locations = {
	:Americas => "ext-gen18",
	:JAPAC  => "ext-gen21",
	:EMEA => "ext-gen24"
}

Sequel.sqlite(File.expand_path('../../db/setting.db', __FILE__))
class Setting < Sequel::Model; end

LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::INFO
LOGGER.formatter = proc do |severity, datetime, progname, msg|
  "#{datetime}: #{msg}\n"
end

ENV['NO_PROXY'] = ENV['no_proxy'] = '127.0.0.1, localhost'
ENV['HTTP_PROXY'] = ENV['http_proxy'] = 'http://cn-proxy.jp.oracle.com:80/'
ENV['HTTPS_PROXY'] = ENV['https_proxy'] = 'http://cn-proxy.jp.oracle.com:80/'