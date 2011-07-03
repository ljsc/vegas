class VegasFS::Router < Sinatra::Base
  configure :test do
    set :show_exceptions, false
    set :raise_errors, true
  end

  def self.expose(url)
    get(url) { url }
  end

  get '/' do
    {'resources' => ['user', 'tweet']}.to_json
  end

  expose '/user'

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
end

