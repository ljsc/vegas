#!/usr/bin/env ruby
require 'json'
require 'net/http'
require 'uri'
require 'twitter'
require 'oauth'

class VegasFS
  def get_user_info(username)
    url = 'http://api.twitter.com/1/users/show.json?screen_name='+ username
    response = Net::HTTP.get(URI.parse(url))
    info = JSON.parse(response)
  end

  def configure_authentication
    consumer_secret = "18yElxR1Zf8ESVkl3k7XQZxyAPWngz5iM69nbhH7yE"
    consumer_key = "zQ727fZBHDIv36pKhr2Hg"

    Twitter.configure do |config|
      config.consumer_key = consumer_key
      config.consumer_secret = consumer_secret
      config.oauth_token = "157879876-iSPfgtHxw8QSAj6cJl0uYTbDTV1kfxsw8Tgi1QGK"
      config.oauth_token_secret = "XiI1kkuGgvqZNc4mGIGkPxjcr19p9PVxhT7m0M"
    end
  end
end


