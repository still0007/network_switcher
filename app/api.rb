require 'sinatra'

class WifiHelperApp < Sinatra::Base
	get '/' do
		read_file
		erb :'_pswd.html'
  end

  private 
  def read_file
  	file = File.new("/data/network_switcher/.pswd", "r")
		while (line = file.gets)
		    @password = line
		    break
		end
		file.close
  end
end