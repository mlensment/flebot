require 'net/http'
require 'json'
require 'nokogiri'
require 'yaml'
# require_relative 'msg'


class Api
  # attr_accessor :email, :password

  def initialize
    config = YAML.load_file('config.yml')
    @email = config['email']
    @password = config['password']
    login
  end

  def login
    uri = URI('https://fleep.io/api/account/login')
    @https = Net::HTTP.new(uri.host, uri.port)
    @https.use_ssl = true
    @https.read_timeout = 3600

    req = Net::HTTP::Post.new(uri.path)
    req['Content-Type'] = 'application/json'
    req.body = { email: @email, password: @password }.to_json

    res = @https.request(req)
    if res.code != '200'
      puts 'ERROR: Login failed.'
      puts "ERROR: #{res.body}"
      exit
    end

    @cookie = res.get_fields('set-cookie')
    result = JSON.parse(res.body)
    @ticket = result['ticket']
  end

  def poll_messages
    poll_uri = URI('https://fleep.io/api/account/poll')
    event_horizon = 0
    loop do
      begin
        req = Net::HTTP::Post.new(poll_uri.path)
        req['Content-Type'] = 'application/json'
        req['Cookie'] = @cookie
        req.body = { event_horizon: event_horizon, wait: true, ticket: @ticket, poll_flags: ['skip_rest'] }.to_json
        res = @https.request(req)
        result = JSON.parse(res.body)
        event_horizon = result['event_horizon']

        messages = result['stream'].select { |x| x['mk_rec_type'] == 'message' }
        # messages = result['stream']
        messages.each do |raw_msg|
          yield(raw_msg)
        end
      rescue => e
        # If there is a problem with the request e.g timeout, wait for 5 seconds and then try again
        puts "DEBUG: #{e}"
        puts "DEBUG: #{e.backtrace}"
        sleep 5
      end
    end
  end

  def get_conversation_members(conv_id)
    result = request("https://fleep.io/api/conversation/sync/#{conv_id}")
    member_uuids = result['header']['members']

    members = []
    member_uuids.each { |x| members << get_contact_email(x) }
    members
  end

  def get_contact_email(contact_id)
    result = request('https://fleep.io/api/contact/sync', { contact_id: contact_id })
    result['email']
  end

  def send_message(conv_id, msg)
    puts "INFO: Sending message to conversation #{conv_id}..."
    message_uri = URI("https://fleep.io/api/message/send/#{conv_id}")
    req = Net::HTTP::Post.new(message_uri.path)
    req['Content-Type'] = 'application/json'
    req['Cookie'] = @cookie
    req.body = { message: msg, ticket: @ticket }.to_json

    res = @https.request(req)
    if res.code == '200'
      puts 'INFO: Message sent.'
    else
      puts 'ERROR: Failed to send the message.'
      puts "ERROR: #{res.body}"
    end
  end

  private
  def request(url, params = {})
    uri = URI(url)
    req = Net::HTTP::Post.new(uri.path)
    req['Content-Type'] = 'application/json'
    req['Cookie'] = @cookie
    req.body = { ticket: @ticket }.merge(params).to_json

    res = @https.request(req)
    if res.code == '200'
      return JSON.parse(res.body)
    else
      puts 'ERROR: Failed to query the API.'
      puts "ERROR: #{res.body}"
    end
  end
end