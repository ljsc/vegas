require File.expand_path('../spec_helper.rb', File.dirname(__FILE__))

require 'vegasfs/router'

describe VegasFS::Router do
  include Rack::Test::Methods

  def app
    VegasFS::Router.new
  end

  it "should list top level services" do
    get '/'
    last_response.body.should include("user")
    last_response.body.should include("tweet")
  end

  describe "getting user information" do
    it "should return user information" do
      Twitter.stub(:user) {
        user = double("user")
        user.stub(:name) {'Lou Scoras'}
        user.stub(:screen_name) {'ljsc'}
        user.stub(:name) { 'Lou Scoras' }
        user.stub(:followers_count) { 1000 }
        user.stub(:statuses_count) { 5000 }
        user.stub(:location) { 'Washington, DC' }
        user
      }

      Twitter.should_receive(:user).with('ljsc')

      get '/user/ljsc.txt'

      last_response.body.should include("name: Lou Scoras")
      last_response.body.should include("screen_name: ljsc")
      last_response.body.should include("followers: 1000")
      last_response.body.should include("statuses: 5000")
      last_response.body.should include("location: Washington, DC")
    end
  end

  describe "getting a picture from a tweet" do
    before do
      @tweet, @parser = double("tweet"), double("parser")

      Twitter.stub(:status).and_return(@tweet)
      VegasFS::Parsers::Image.stub(:new).and_return(@parser)

      @tweet.stub(:text).and_return("tweet text with yfrog url: yfrog.com/fooJ")
      @parser.stub(:image_data).and_return("XBINARYDATAX")
    end

    it "should ask twitter for the correct tweet" do
      Twitter.should_receive(:status).with("12345").and_return(@tweet)
      get '/tweet/12345.jpg'
    end

    it "should create a new parser with the tweet body" do
      VegasFS::Parsers::Image.should_receive(:new).
        with("tweet text with yfrog url: yfrog.com/fooJ").and_return(@parser)
      get '/tweet/12345.jpg'
    end

    it "should return the image data" do
      get '/tweet/12345.jpg'
      last_response.body.should == "XBINARYDATAX"
    end

    it "should set the content type correctly" do
      get '/tweet/12345.jpg'
      last_response['Content-Type'].should == 'image/jpeg'
    end
  end
end
