#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'net/http'
require 'uri'

class VegasFS
  def get_user_info(username)
    url = 'http://api.twitter.com/1/users/show.json?screen_name='+ username
    response = Net::HTTP.get(URI.parse(url))
    info = JSON.parse(response)
  end
  def return_zero

  end 
end


