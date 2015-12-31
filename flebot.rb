#!/usr/bin/env ruby
ENV['FLEBOT_ENV'] ||= 'development'

require_relative 'lib/api'
require 'bundler'
Bundler.require(:default, ENV['FLEBOT_ENV'])

$logger = Logging.logger['default']
$logger.level = :info
if ENV['FLEBOT_ENV'] == 'development'
  $logger.add_appenders Logging.appenders.stdout
elsif ENV['FLEBOT_ENV'] == 'production'
  $logger.add_appenders Logging.appenders.file("log/#{ENV['FLEBOT_ENV']}.log")
end

class Flebot
  class << self
    def help
      apps = Flebot.constants.map(&Flebot.method(:const_get)).grep(Class)
      apps.map! { |x| x.name.to_s.gsub('Flebot::', '').downcase }
      return "Hello, I am Flebot. I currently have the following Apps: #{apps.join(', ')}\n"\
      "Launch the application by typing 'flebot [app name]'"
    end

    def listen
      $logger.info 'Starting Flebot'
      api = Api.new
      api.poll_messages do |raw_msg|
        conv_id = raw_msg['conversation_id']
        msg_body = Nokogiri::HTML(raw_msg['message']).text
        next unless msg_body.start_with?('flebot')

        app_class = find_app(msg_body)
        unless app_class
          api.send_message(conv_id, help)
          next
        end

        sender = api.get_contact_email_and_handle(raw_msg['account_id'])
        members = api.get_conversation_members(conv_id)

        app = app_class.new(msg_body, sender, members)
        response = app.execute
        api.send_message(conv_id, response)
      end
    end

    def find_app(msg_body)
      app_name = msg_body.split(' ')[1]
      klass = Object.const_get("Flebot::#{app_name.capitalize}")
      klass.name.to_s.split("::").first == 'Flebot' ? klass : nil
      rescue NameError
        nil
    end
  end
end

if ARGV.include?('--start')
  Flebot.listen
end
