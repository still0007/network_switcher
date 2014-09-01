require ::File.expand_path('../app/api', __FILE__)

run Rack::URLMap.new(
  '/'         => WifiHelperApp
)