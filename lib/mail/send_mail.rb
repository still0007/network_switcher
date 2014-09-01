require 'erb'

module Mailer
  def self.send_mail to, subject, password, time_zone
    html = get_html(to, subject, password, time_zone)
    File.open("1", 'w') { |file| file.write(html) }
    %x( cat 1 | /usr/sbin/sendmail -t )
    %x( rm 1 )
  end

  def self.get_html to, subject, password, time_zone
    template_file = File.open(File.expand_path("../template/template.html.erb", __FILE__), 'r').read
    content = ERB.new(template_file).result(binding)
    
    template_file = File.open(File.expand_path("../template/header_#{time_zone}.erb", __FILE__), 'r').read
    header = ERB.new(template_file).result(binding)

    header + content
  end

end
