require 'spec_helper'
require_relative '../flebot'

RSpec.describe Flebot do
  it 'returns help text' do
    Flebot.help.is_a?(String).should == true
    Flebot.help.length.should > 10
  end

  it 'finds an app' do
    Flebot.find_app('flebot random').should be_nil
    Flebot.find_app('flebot books').should == Flebot::Books
  end

  it 'polls messages and executes an app' do
    api = instance_double("Api")
    msg = '<msg><p>test message</p></msg>'
    conv_id = 'aea1628e-0591-4fc5-8c0a-2d292360804a'
    allow(api).to receive(:poll_messages).and_yield('{"profile_id"=>"9592d5e5-ac0a-4441-835a-74b96c31cc38", "inbox_nr"=>182, "message"=>"' + msg + '", "mk_rec_type"=>"message", "account_id"=>"9592d5e5-ac0a-4441-835a-74b96c31cc38", "tags"=>[], "mk_message_type"=>"text", "store_time"=>"2015-12-23 22:19:24.871181+00", "posted_time"=>1450909165, "conversation_id"=>"' + conv_id + '", "message_nr"=>185, "assignee_ids"=>[], "prev_message_nr"=>184, "is_url_preview_disabled"=>false}')
    allow(api).to receive(:get_contact_email).and_return('user1@test.com')
    allow(api).to receive(:get_conversation_members).and_return(['user1@test.com', 'user2@test.com'])
    allow(api).to receive(:send_message).and_return('{"header"=>{"snooze_time"=>0, "has_taskboard"=>false, "mk_alert_level"=>"default", "topic"=>"", "has_pinboard"=>false, "autojoin_url"=>"https://fleep.io/chat/rqFijgWRT8WMCi0pI2CASg", "topic_message_nr"=>1, "last_message_time"=>1450917815.259061, "can_post"=>true, "read_message_nr"=>196, "join_message_nr"=>1, "mk_rec_type"=>"conv", "profile_id"=>"9592d5e5-ac0a-4441-835a-74b96c31cc38", "snooze_interval"=>0, "inbox_weight"=>1450917814, "last_inbox_nr"=>193, "is_automute"=>false, "last_message_nr"=>196, "conversation_id"=>"aea1628e-0591-4fc5-8c0a-2d292360804a", "send_message_nr"=>1, "is_premium"=>true, "has_email_subject"=>false, "unread_count"=>0, "creator_id"=>"9592d5e5-ac0a-4441-835a-74b96c31cc38", "inbox_message_nr"=>196, "show_message_nr"=>196, "has_task_archive"=>false}, "stream"=>[{"snooze_time"=>0, "has_taskboard"=>false, "mk_alert_level"=>"default", "topic"=>"", "has_pinboard"=>false, "autojoin_url"=>"https://fleep.io/chat/rqFijgWRT8WMCi0pI2CASg", "topic_message_nr"=>1, "last_message_time"=>1450917815.259061, "can_post"=>true, "read_message_nr"=>196, "join_message_nr"=>1, "mk_rec_type"=>"conv", "profile_id"=>"9592d5e5-ac0a-4441-835a-74b96c31cc38", "snooze_interval"=>0, "inbox_weight"=>1450917814, "last_inbox_nr"=>193, "is_automute"=>false, "last_message_nr"=>196, "conversation_id"=>"aea1628e-0591-4fc5-8c0a-2d292360804a", "send_message_nr"=>1, "is_premium"=>true, "has_email_subject"=>false, "unread_count"=>0, "creator_id"=>"9592d5e5-ac0a-4441-835a-74b96c31cc38", "inbox_message_nr"=>196, "show_message_nr"=>196, "has_task_archive"=>false}, {"profile_id"=>"9592d5e5-ac0a-4441-835a-74b96c31cc38", "inbox_nr"=>193, "message"=>"<msg><p>show flebot help here</p></msg>", "mk_rec_type"=>"message", "account_id"=>"9592d5e5-ac0a-4441-835a-74b96c31cc38", "tags"=>[], "mk_message_type"=>"text", "store_time"=>"2015-12-24 00:43:35.259061+00", "posted_time"=>1450917815, "conversation_id"=>"aea1628e-0591-4fc5-8c0a-2d292360804a", "message_nr"=>196, "prev_message_nr"=>195}], "result_message_nr"=>196}')
    allow(Api).to receive(:new) { api }

    Flebot.listen

    expect(api).to receive(:send_message).with('aea1628e-0591-4fc5-8c0a-2d292360804a', 'bla')
  end
end
