require 'bundler'
Bundler.setup

base = File.expand_path File.dirname(__FILE__)

Dir[File.join(base, '*.rb')].each do |file|
  require file
end
