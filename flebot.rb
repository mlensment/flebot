#!/usr/bin/env ruby
require 'pry'
Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each { |file| require file }
#
class Flebot
  class << self
    def help
      'show flebot help here'
    end

    def find_app(msg_body)
      app_name = msg_body.split(' ')[1]

      app_files = Dir.entries('lib/apps').select { |f| f.end_with?('.rb') }
      app_names = app_files.map { |x| x.gsub('.rb', '') }
      return unless app_names.include?(app_name)

      Object.const_get(app_name.capitalize)
    end
  end
end

api = Api.new
api.poll_messages do |raw_msg|
  conv_id = raw_msg['conversation_id']
  msg_body = Nokogiri::HTML(raw_msg['message']).text
  next unless msg_body.start_with?('flebot')

  app_class = Flebot.find_app(msg_body)
  unless app_class
    api.send_message(conv_id, Flebot.help)
    next
  end

  sender = api.get_contact_email(raw_msg['account_id'])
  members = api.get_conversation_members(conv_id)

  app = app_class.new(msg_body, sender, members)
  response = app.execute
  api.send_message(conv_id, response)
end
