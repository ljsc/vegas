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
end

