require_relative 'apps/books'

class Msg
  attr_accessor :body, :conv_id, :sender, :users

  def initialize(raw_msg)
    @body = Nokogiri::HTML(raw_msg['message']).text
    @conv_id = raw_msg['conversation_id']
    @sender = nil # TODO
    @users = nil # TODO
  end

  def response
    return unless app
    @response ||= app.execute
  end

  def app
    return Books.new(self) if @body.match /^flebot books/
  end
end
