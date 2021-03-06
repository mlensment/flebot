require 'net/http'
require 'yaml'

class Api
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
      $logger.error 'Login failed.'
      $logger.error "#{res.body}"
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
        result = request('https://fleep.io/api/account/poll', {
          event_horizon: event_horizon, wait: true, poll_flags: ['skip_rest']
        })

        event_horizon = result['event_horizon']
        # listen for only messages
        messages = result['stream'].select { |x| x['mk_rec_type'] == 'message' }
        messages.each do |raw_msg|
          yield(raw_msg)
        end
      rescue => e
        # If there is a problem with the request e.g timeout, wait for 5 seconds and then try again
        $logger.error "#{e}"
        $logger.error "#{e.backtrace.join("\n")}"
        sleep 5
      end
    end
  end

  def get_conversation_members(conv_id)
    result = request("https://fleep.io/api/conversation/sync/#{conv_id}")
    member_uuids = result['header']['members']

    members = []
    member_uuids.each { |x| members << get_contact_email_and_handle(x) }
    members
  end

  def get_contact_email_and_handle(contact_id)
    result = request('https://fleep.io/api/contact/sync', { contact_id: contact_id })
    if result['fleep_address']
      { result['email'] => "@#{result['fleep_address']}"  }
    else
      { result['email'] => "@#{result['email'].split('@').first}"  }
    end
  end

  def send_message(conv_id, msg)
    $logger.info "Sending message to conversation #{conv_id}..."
    request("https://fleep.io/api/message/send/#{conv_id}", message: msg)
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
      $logger.error 'Failed to query the API.'
      $logger.error "#{res.body}"
    end
  end
end
