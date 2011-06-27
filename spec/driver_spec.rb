require File.expand_path('spec_helper.rb', File.dirname(__FILE__))

describe VegasFS::Driver do
  describe "connected to localhost port 777" do
    before do
      @vegas = VegasFS::Driver.connect(:host => 'localhost', :port => 777)
    end

    it "should submit GET request on read_file calls" do
      stub_request(:any, 'localhost:777/foo/bar')
      @vegas.read_file("/foo/bar")

      a_request(:get, "http://localhost:777/foo/bar").should have_been_made
    end
  end
end
