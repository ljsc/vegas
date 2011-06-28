require 'rubygems'
require 'bundler'
Bundler.require(:test)

require 'webmock/rspec'

ENV['RACK_ENV']= 'test'

require 'vegasfs'


