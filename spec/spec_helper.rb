require 'bundler'
ENV['FLEBOT_ENV'] ||= 'test'
Bundler.require(:default, ENV['FLEBOT_ENV'])
