# Helper Module to store twitter accessing methods
# @author: Catalino Cuadrado

module VegasFS::TwitterHelpers
  ##
  # gets user info for a specific username and returns it as JSON.
  # @param [String] username The short twitter username (ex @AgentJose1) of the person you want to get
  #  
  def get_user_info(username)
    url = 'http://api.twitter.com/1/users/show.json?screen_name='+ username
    response = Net::HTTP.get(URI.parse(url))
    info = JSON.parse(response)
  end

  ## 
  # gets the user's @mentions and returns them as JSON.
  def get_user_mentions
    client = configure_authentication
    mentions = client.mentions
    client.end_session
    mentions.to_json
  end

  ## 
  # gets a tweet by tweet ID
  # @params id [long] Long integer number that represents the specific tweet
  def get_tweet_by_id(id)
    tweet = Twitter.status(id)
    {:message => tweet.text, :author => tweet.user.screen_name, :date => tweet.created_at} 
  end
  ## 
  # configures authentication with the Twitter server and returns a client object to be used for operations
  # Key creation neesd to be done manually and then pasted into the software because callbacks are not supported. 
  def configure_authentication
    consumer_secret = "18yElxR1Zf8ESVkl3k7XQZxyAPWngz5iM69nbhH7yE"
    consumer_key = "zQ727fZBHDIv36pKhr2Hg"

    Twitter.configure do |config|
      config.consumer_key = consumer_key
      config.consumer_secret = consumer_secret
      config.oauth_token = "157879876-iSPfgtHxw8QSAj6cJl0uYTbDTV1kfxsw8Tgi1QGK"
      config.oauth_token_secret = "XiI1kkuGgvqZNc4mGIGkPxjcr19p9PVxhT7m0M"
      Twitter::Client.new
    end
  end
  ##
  # gets latest tweets in a user's timeline
  # @params num_of_tweets [Integer] Number of Tweets you want to return in the timeline. 

  def get_latest_tweets(num_of_tweets)
    client = configure_authentication
    latest = client.home_timeline({:count => num_of_tweets})
    client.end_session
    info = latest.to_json
  end 
  ##
  # Returns all tweets with a hashtag tag
  # @params tag [String] Hashtag you want to return.
  def get_hashtag(tag)
    Twitter::Search.new.hashtag(tag).fetch.to_json
  end
end

##
# Router Class that handles routes and http verbs from the fusefs driver to the twitter webservice 
class VegasFS::Router < Sinatra::Base
 include VegasFS::TwitterHelpers
  configure :test do
    set :show_exceptions, false
    set :raise_errors, true
  end

  def self.expose(url)
    get(url) { url }
  end
# Sets up the default routes
  get '/' do
    {'resources' => ['user', 'tweet']}.to_json
  end

  expose '/user'
  ## 
  # @author:catalino
  # Returns the user mentions as text 
  get '/user/mentions.txt' do 
    mentions = JSON.parse(get_user_mentions)
    output_file = mentions.map {|t| 'Screen Name:' + t['user']['screen_name'] + "\n" + 'Body:' + t['text'] + "\n" + 'Date:' + t['created_at'] + "\n\n"}.to_s
    [200,{'Content-Type' => 'text'},output_file]
  end
  ## 
  # @author: ljsc
  # Returns user information 
  # @params user [String] the short name without the @ (ex. /user/agentjose1.txt) 
  get '/user/:user.txt' do
    begin
      user = Twitter.user(params[:user])

      %Q{name: #{user.name}
         screen_name: #{user.screen_name}
         followers: #{user.followers_count}
         statuses: #{user.statuses_count}
         location: #{user.location}
      }.gsub(/^       /, '')
    rescue Twitter::NotFound
      [404, 'User not found!']
    end
  end


  expose '/tweet'
  ##
  # @author: ljsc
  # gets a tweet's image from a certain tweet ID  
  # @params c [Integer] ID is passed from the regex. 
  get %r{/tweet/(\d+).jpe?g} do |c|
    begin
      parser = VegasFS::Parsers::Image.new(Twitter.status(c).text)
      if parser.contains_jpeg?
        [200, {'Content-Type' => 'image/jpeg'}, parser.image_data]
      else
        [404, 'No image contained in tweet']
      end
    rescue Twitter::NotFound
      [404, 'Tweet not found!']
    end
  end
  ##
  # @author: ljsc
  # Gets a png image
  # @params c [Integer] taken from the regex
  get %r{/tweet/(\d+).png} do |c|
    begin
      parser = VegasFS::Parsers::Image.new(Twitter.status(c).text)
      if parser.contains_png?
        [200, {'Content-Type' => 'image/png'}, parser.image_data]
      else
        [404, 'No image contained in tweet']
      end
    rescue Twitter::NotFound
      [404, 'Tweet not found!']
    end
  end
  ## 
  #@author:ljsc
  #Fetches an HTML page
  #@params c [Integer] taken from the regex
  get %r{/tweet/(\d+).html} do |c|
    begin
      parser = VegasFS::Parsers::Link.new(Twitter.status(c).text)
      if parser.contains_links?
        [200, {'Content-Type' => 'text/html'}, parser.link_html]
      else
        [404, 'No links found in tweet']
      end
    rescue Twitter::NotFound
      [404, 'Tweet not found!']
    end
  end

  ##
  #@author:catalino
  # gets the tweet by ID and returns the result as text
  #@params tweet_id [Integer] taken from the regex
  get %r{/tweet/(\d+).txt} do |tweet_id|
    result = get_tweet_by_id(tweet_id)
    'Text: ' + result[:message] + '\n Author:' + result[:author] + '\n Date Created: ' + result[:date]
  end 
  ##
  # @author: catalino
  # fetches the latest 20 tweets 
  get '/tweet/latest.txt' do 
    latest = JSON.parse(get_latest_tweets(20))
    output_file = latest.map {|t| 'Screen Name:' + t['user']['screen_name'] + "\n" + 'Body:' + t['text'] + "\n" +     'Date:' + t['created_at'] + "\n\n"}.to_s
   [200,{'Content-Type' => 'text'},output_file]
  end 

  ## 
  # @author: catalino
  # Creates a new tweet based off of params passed by the Sinatra handler
  post '/tweet/new.txt' do
    client = configure_authentication
    client.update(request.body)
  end
  
  ##
  # @author: catalino
  # Gets tweets containing specified hashtag with default search parameters. 
  # @params :tag [String] is taken from the route
  expose '/hashtag'
  get '/hashtag/:tag.txt' do 
    htag = params[:tag]
    tweets = JSON.parse(get_hashtag(htag))
    
    output_file = tweets.empty? ?  "No hashtag Found for tag #{htag}" : tweets.map {|t| 'Screen Name:' + t['from_user'] + "\n" + 'Body:' + t['text'] + "\n" + 'Date:' + t['created_at'] + "\n\n"}.to_s  
    [200,{'Content-Type' => 'text'},output_file]
  end
end

