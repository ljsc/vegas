require File.expand_path('spec_helper.rb', File.dirname(__FILE__))

describe VegasFS::Driver do
  describe "connected to localhost port 777" do
    before do
      @vegas = VegasFS::Driver.connect(:host => 'localhost', :port => 777)
    end

    it "should submit a GET request on read_file calls" do
      stub_request(:get, 'localhost:777/foo/bar')
      @vegas.read_file("/foo/bar")

      a_request(:get, "http://localhost:777/foo/bar").should have_been_made
    end

    it "should submit a GET request when listing directories" do
      stub_request(:get, 'localhost:777/foo/bars')
      @vegas.contents("/foo/bars")

      a_request(:get, "http://localhost:777/foo/bars").should have_been_made
    end

    it "should submit a POST request when writing a file" do
      stub_request(:post, 'localhost:777/gimmie/doughnut.txt')
      @vegas.write_to('/gimmie/doughnut.txt', "Homer likes!")

      a_request(:post, "http://localhost:777/gimmie/doughnut.txt").with(
        :body => "Homer likes!"
      ).should have_been_made
    end
  end
end
