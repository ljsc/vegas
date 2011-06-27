#!/usr/bin/env ruby

# Here's a working example with pulling some data from twitter. To get this
# running I did the following steps.
#
# 1. Downlaod MacFuse and Install
# 2. Install Fusefs for OSX
#        $ gem install fusefs-osx
#    This only works with ruby 1.8 apparently. It will not compile correctly
#    with 1.9.2. 
# 3. Create a directory to mount to:
#        $ mkdir tweets
# 4. Mount the file system:
#        $ ruby current_timeline tweets/ &
# 5. Play around with it. You can use ls to get the one file name, view the tweets. Also, try out
#        $ du -sh tweets to see the size part in action
#    And on that note; I had to implement the size call, otherwise it would
#    return a 0byte lenght file resposne. Annoying, but apparently that is
#    required on OSX (as apposed to Linux, where Fuse was originally developed
#    for).
# 6. When you are done, you can kill the ruby driver as per normal, but this
#    won't unmount the fuse volume. You can do this with the regular OSX tools.
#        $ umount tweets/
require 'rubygems'
require 'fusefs'
require 'json'
require 'net/http'
require 'uri'

URL = 'http://api.twitter.com/1/statuses/user_timeline.json?screen_name=agentjose1'

class VegasFS
  def contents(path)
    ['current.txt']
  end
  def file?(path)
    path == '/current.txt'
  end
  def read_file(path)
    response = Net::HTTP.get(URI.parse(URL))
    tweets = JSON.parse(response).map {|t| t['text']}
    tweets.join("\n")
  end
  def size(path)
    response = Net::HTTP.start('api.twitter.com', 80) do |http|
      http.head '/1/statuses/user_timeline.json?screen_name=agentjose1'
    end
    response['Content-Length'].to_i
  end
end

FuseFS.set_root(VegasFS.new)
FuseFS.mount_under ARGV.shift
FuseFS.run

