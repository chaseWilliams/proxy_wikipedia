require 'bundler'
Bundler.setup

require 'sinatra'
require 'rest-client'
require 'area'
require 'redis'

base = File.expand_path File.dirname(__FILE__)

Dir[File.join(base, '*.rb')].each do |file|
  require file
end
