class VegasFS::Router < Sinatra::Base
  configure :test do
    set :show_exceptions, false
    set :raise_errors, true
  end

  get '/' do
    {'resources' => ['user', 'tweet']}.to_json
  end

  get '/user/:user.txt' do
    user = Twitter.user(params[:user])

    %Q{name: #{user.name}
       screen_name: #{user.screen_name}
       followers: #{user.followers_count}
       statuses: #{user.statuses_count}
       location: #{user.location}
    }.gsub(/^       /, '')
  end

  get %r{/tweet/(\d+).jpg} do |c|
    image = VegasFS::Parsers::Image.new(Twitter.status(c).text).image_data
    [200, {'Content-Type' => 'image/jpeg'}, image]
  end

  get '/tweets/latest.txt' do 
      get_latest_tweets(20)
  end 


# Twitter Helper Methods
  def get_user_info(username)
    url = 'http://api.twitter.com/1/users/show.json?screen_name='+ username
    response = Net::HTTP.get(URI.parse(url))
    info = JSON.parse(response)
  end

  def get_user_mentions
    client = configure_authentication
    mentions = client.mentions
    client.end_session
    mentions.to_json
  end

  def get_tweet_by_id(id)
    tweet = Twitter.status(id)
    {:message => tweet.text, :author => tweet.user.screen_name, :date => tweet.created_at} 
  end
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

  def get_latest_tweets(num_of_tweets)
    client = configure_authentication
    latest = client.home_timeline({:count => num_of_tweets})
    info = latest.to_json
  end 



end

