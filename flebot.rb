#!/usr/bin/env ruby
ENV['FLEBOT_ENV'] ||= 'development'

require_relative 'lib/api'
require 'bundler'
Bundler.require(:default, ENV['FLEBOT_ENV'])

class Flebot
  class << self
    def help
      'show flebot help here'
    end

    def listen
      puts 'INFO: Starting Flebot'
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
