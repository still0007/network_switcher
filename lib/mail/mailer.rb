require 'mail'

module Mailer
  # Set up delivery defaults to use Gmail
  def self.send_mail(to, subject, html)
    Mail.defaults do
      delivery_method :smtp, {
        :address => 'smtp.gmail.com',
        :port => '587',
        :user_name => '<your.mail.address>',
        :password => '<your.mail.password',
        :authentication => :plain,
        :enable_starttls_auto => true
      }
    end

    mail = Mail.new do
      from      "<FROM>"
      to        to
      subject   subject

      html_part do
        content_type 'text/html; charset=UTF-8'
        body html
      end
    end

    mail.deliver!
  end

  def get_html password
    template_file = File.open(File.expand_path("../template/template.html.erb", __FILE__), 'r').read
    ERB.new(template_file).result(binding)
  end
end
