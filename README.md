# Flebot is a [Fleep](https://fleep.io) bot written in Ruby
Flebot listens to all the Fleep chats and when it recognizes a specific pattern (command), the message along with some arguments is passed into an App.  

Command example:
```
flebot weather tomorrow at 2:30
```

`flebot` - keyword for Flebot to parse the message  
`weather` - app name  
`tomorrow at 2:30` - rest of the message

To see which arguments are passed into an App, see [below](https://github.com/mlensment/flebot/#apps).

## Requirements
Make sure you have Ruby 2.2.3 installed.

## Setup
```
git clone git@github.com:mlensment/flebot.git && cd flebot
gem install bundler
bundle
```

Rename `config-example.yml` to `config.yml` and configure username and password.

## Apps
Flebot integrates with Apps. Apps are regular rubygems and they must implement specific [interface](spec/app_spec.rb) and should have their own functional tests.
App example can be found [here](https://github.com/mlensment/flebot-books/)  

Arguments passed into an app are:
* The message itself
* Email + handle of the user who sent the message
* List of chat members' emails with corresponding fleep handles

### Testing your App interface within Flebot
To test your App interface add the gem to Flebot's Gemfile and install it, then run app spec:
```
rspec spec/app_spec.rb
```

If tests pass, your App interface is compatible with Flebot standard.

## Usage
Start the robot in development mode:
`ruby flebot.rb --start`

To run the bot in production configuration, prepend `FLEBOT_ENV=production` to the command.

## Deployment
You can use whatever deployment tool you want, but [Mina](https://github.com/mina-deploy/mina) is used by default. Follow their user guide to set up your project. Refer to [deployment configuration](config/deploy.rb) to see the example configuration. Note that the restart task is actually run locally and in different ssh session since it's started with `nohup`.

### Shared paths
In default configuration shared paths are directories app-data and log and file config.yml, that mean those paths are not overwritten on deploy.

Open Fleep and type `flebot` into one of your chats. Flebot should display some help into that same chat.

## Running tests
```
rspec
```
