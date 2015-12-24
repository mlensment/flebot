require 'spec_helper'
require_relative '../flebot'

RSpec.shared_examples "an app" do
  it 'takes three arguments' do
    described_class.new('felbot books', {'user1@test.ee' => '@user1'}, [{'user1@test.ee' => '@user1'}, {'user2@test.ee' => '@user2'}])
  end

  it 'has a help method' do
    app = described_class.new('felbot books', {'user1@test.ee' => '@user1'}, [{'user1@test.ee' => '@user1'}, {'user2@test.ee' => '@user2'}])
    expect(app.help).to be_a String
    expect(app.help.length).to be > 0
  end

  it 'has an execute method' do
    described_class.name.downcase
    app = described_class.new('felbot books', {'user1@test.ee' => '@user1'}, [{'user1@test.ee' => '@user1'}, {'user2@test.ee' => '@user2'}])
    expect(app.execute).to be_a String
    expect(app.execute.length).to be > 0
  end
end

Flebot.constants.map(&Flebot.method(:const_get)).grep(Class).each do |app_class|
  RSpec.describe app_class do
    it_behaves_like "an app"
  end
end
