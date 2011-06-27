require File.expand_path('../spec_helper.rb', File.dirname(__FILE__))

describe VegasFS::Driver do
  describe "connected to localhost port 777" do
    before do
      @vegas = VegasFS::Driver.connect(:host => 'localhost', :port => 777)
    end

    describe "accessing a file" do
      it "should submit a GET request on read_file calls" do
        stub_request(:get, 'localhost:777/foo/bar')
        @vegas.read_file("/foo/bar")

        a_request(:get, "http://localhost:777/foo/bar").should have_been_made
      end

      it "should return the body contents of a GET request" do
        stub_request(:get, 'localhost:777/foo/bar').to_return(:body => "Baz!")
        @vegas.read_file("/foo/bar").should == "Baz!"
      end
    end

    describe "accessing a directory" do
      it "should submit a GET request for the contents" do
        stub_request(:get, 'localhost:777/foo/bars')
        @vegas.contents("/foo/bars")

        a_request(:get, "http://localhost:777/foo/bars").should have_been_made
      end

      it "should return an empty array of files if json can't be parsed" do
        stub_request(:get, 'localhost:777/foo/bars')
        @vegas.contents("/foo/bars").should == []
      end

      it "should return a list of resources" do
        stub_request(:get, 'localhost:777/smurfs').to_return(
          :body => %q[{"smurfs":["pappa", "brainy", "smurfette"]}],
          :headers => {'Content-Type' => 'application/json'}
        )
        @vegas.contents('/smurfs').should == ['pappa', 'brainy', 'smurfette']
      end
    end

    it "should submit a POST request when writing a file" do
      stub_request(:post, 'localhost:777/gimmie/doughnut.txt')
      @vegas.write_to('/gimmie/doughnut.txt', "Homer likes!")

      a_request(:post, "http://localhost:777/gimmie/doughnut.txt").with(
        :body => "Homer likes!"
      ).should have_been_made
    end

    describe "querying for file sizes" do
      it "should submit a HEAD request" do
        stub_request(:head, 'localhost:777/bloated.xml')
        @vegas.size('/bloated.xml')

        a_request(:head, "http://localhost:777/bloated.xml").should have_been_made
      end

      it "should return the Content-Length" do
        large_and_bloated = 1024 * 1024 * 1024
        stub_request(:head, 'localhost:777/bloated.xml').to_return(
          :headers => {'Content-Length' => large_and_bloated }
        )
        @vegas.size('/bloated.xml').should == large_and_bloated
      end
    end

    it "should submit a DELETE request to delete files" do
      stub_request(:delete, 'localhost:777/delete_me.png')
      @vegas.delete('/delete_me.png')

      a_request(:delete, "http://localhost:777/delete_me.png").should have_been_made
    end
  end
end
