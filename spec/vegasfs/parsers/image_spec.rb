require File.expand_path('../../spec_helper.rb', File.dirname(__FILE__))

RSpec::Matchers.define :contain_images do
  match do |actual|
    actual.contains_images?
  end
end

describe VegasFS::Parsers::Image do
  describe "determining image type" do
    let(:parser) { VegasFS::Parsers::Image.new(tweet) }

    describe "on a tweet with a png" do
      let(:tweet) { "@arielniweihuang http://bit.ly/ihhtC0 the work in progress.
        Really basic at moment http://yfrog.com/h77tnfp"}
      it "should detect the correct type" do
        parser.contains_jpeg?.should be_false
        parser.contains_png?.should be_true
      end
    end

    describe "on a tweet with a jpeg" do
      let(:tweet) { "Take a book, leave a book. http://yfrog.com/h0fr6nxj" }
      it "should detect the correct type" do
        parser.contains_jpeg?.should be_true
        parser.contains_png?.should be_false
      end
    end
  end

  describe "parsing an tweet with an image" do
    let(:tweet) { "Take a book, leave a book. http://yfrog.com/h0fr6nxj" }
    let(:parser) { VegasFS::Parsers::Image.new(tweet) }

    it "should detect there is an image available" do
      parser.should contain_images
    end

    it "should extract the picture url" do
      parser.url.should == "http://yfrog.com/h0fr6nxj"
    end

    it "should download the image" do
      redirect = 'http://desmond.yfrog.com/Himg612/scaled.php?tn=0&server=612' +
                             '&filename=fr6nx.jpg&xsize=640&ysize=640'

      stub_request(:get, 'http://yfrog.com/h0fr6nxj:medium').to_return(
        :status => 301, :headers => { 'Location' => redirect })

      stub_request(:get, redirect).to_return(:body => 'THE ENCODED IMAGE')
                        
      parser.image_data.should == 'THE ENCODED IMAGE'

      a_request(:get, 'http://yfrog.com/h0fr6nxj:medium').should have_been_made
      a_request(:get, redirect).should have_been_made
    end
  end

  describe "parsing a tweet without the protocol in the url" do
    let(:tweet) { "Take a book, leave a book. yfrog.com/h0fr6nxj" }
    let(:parser) { VegasFS::Parsers::Image.new(tweet) }

    it "should still detect the image" do
      parser.should contain_images
    end
  end

  describe "parsing an tweet without an image" do
    let(:tweet) { "This is a tweet without images http://www.google.com/" }
    let(:parser) { VegasFS::Parsers::Image.new(tweet) }

    it "should not detect any images" do
      parser.should_not contain_images
    end
    
    it "should return nil for the image url" do
      parser.url.should be_nil
    end
  end

  describe "parsing a tweet with multiple images" do
    let(:tweet) { "Multi image tweet FTW! http://yfrog.com/yes http://yfrog.com/no" }
    let(:parser) { VegasFS::Parsers::Image.new(tweet) }

    it "should detect images" do
      parser.should contain_images
    end

    it "should return the first image url" do
      parser.url.should == 'http://yfrog.com/yes'
      parser.url.should_not == 'http://yfrog.com/no'
    end
  end
end
