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

# require 'net/http'
# require 'json'
# require 'nokogiri'
#
# ### Configuration
# email = '***@***'
# password = '***'
# pattern = /^test$/
# ###
#
# uri = URI('https://fleep.io/api/account/login')
# https = Net::HTTP.new(uri.host, uri.port)
# https.use_ssl = true
# https.read_timeout = 3600
#
# req = Net::HTTP::Post.new(uri.path)
# req['Content-Type'] = 'application/json'
# req.body = { email: email, password: password }.to_json
#
# res = https.request(req)
# if res.code != '200'
#   puts 'ERROR: Login failed.'
#   puts "ERROR: #{res.body}"
#   exit
# end
#
# cookie = res.get_fields('set-cookie')
# result = JSON.parse(res.body)
# ticket = result['ticket']
#
# poll_uri = URI('https://fleep.io/api/account/poll')
# event_horizon = 0
# loop do
#   begin
#     req = Net::HTTP::Post.new(poll_uri.path)
#     req['Content-Type'] = 'application/json'
#     req['Cookie'] = cookie
#     req.body = { event_horizon: event_horizon, wait: true, ticket: ticket, poll_flags: ['skip_rest'] }.to_json
#     res = https.request(req)
#     result = JSON.parse(res.body)
#     event_horizon = result['event_horizon']
#
#     # Select only messages from the response
#     messages = result['stream'].select { |x| x['mk_rec_type'] == 'message' }
#     messages.each do |msg|
#       next unless Nokogiri::HTML(msg['message']).text.match(pattern)
#       puts "INFO: Sending message to conversation #{msg['conversation_id']}..."
#
#       message_uri = URI("https://fleep.io/api/message/send/#{msg['conversation_id']}")
#       req = Net::HTTP::Post.new(message_uri.path)
#       req['Content-Type'] = 'application/json'
#       req['Cookie'] = cookie
#       req.body = { message: 'Message from the Flebot: Hello World!', ticket: ticket }.to_json
#
#       res = https.request(req)
#       if res.code == '200'
#         puts 'INFO: Message sent.'
#       else
#         puts 'ERROR: Failed to send the message.'
#         puts "ERROR: #{res.body}"
#       end
#     end
#   rescue => e
#     # If there is a problem with the request e.g timeout, wait for 5 seconds and then try again
#     puts "DEBUG: #{e}"
#     sleep 5
#   end
# end
