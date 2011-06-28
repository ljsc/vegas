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
end
