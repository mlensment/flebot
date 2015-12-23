# Flebot is a [Fleep](https://fleep.io) bot written in Ruby
This repository contains an example how to integrate with Fleep API by using Ruby.
The bot monitors chats and detects when someone types in a specific pattern.
When this happens, Flebot will send a message to that chat.

By default, the pattern is `test`.

## Requirements
Make sure you have Ruby 2.2.3 installed.

## Setup
```
git clone git@github.com:mlensment/flebot-example.git && cd flebot-example
gem install bundler
bundle
```

Open `flebot.rb` and configure username, password and the pattern you want to match.

## Usage
Execute the script:
`./flebot.rb`

Open Fleep and type your pattern (test) into a chat of your choice, the bot should respond with a message.
