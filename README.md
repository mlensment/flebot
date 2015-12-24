# Flebot is a [Fleep](https://fleep.io) bot written in Ruby
Flebot listens to all the Fleep chats and when it recognizes a specific pattern, the message is passed into an app.  

Standard pattern for passing messages from Fleep to Flebot is:  
`flebot weather tomorrow at 2:30`

`flebot` - keyword for Flebot to parse the message  
`weather` - app name  
`tomorrow at 2:30` - arguments for the app


## Apps
Flebot integrates with apps. Apps are regular rubygems and they must implement specific interface and should have their own tests.
App example can be found [here](https://github.com/mlensment/flebot-example/)  

Arguments passed into an app are:
* The message itself
* Email of the user who sent the message
* List of chat members' emails

## Requirements
Make sure you have Ruby 2.2.3 installed.

## Setup
```
git clone git@github.com:mlensment/flebot.git && cd flebot
gem install bundler
bundle
```

Rename `config-example.yml` to `config.yml` and configure username and password.

## Usage
Start the robot in development mode:
`ruby flebot.rb --start`

For prodcution, pass `FLEBOT_ENV=prodcution` as well.

Open Fleep and type `flebot` into one of your chats. Flebot should display some help into that same chat.

## Running tests
`rspec`
