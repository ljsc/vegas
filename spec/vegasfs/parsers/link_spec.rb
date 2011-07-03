require File.expand_path('../../spec_helper.rb', File.dirname(__FILE__))

RSpec::Matchers.define :contain_links do
  match do |actual|
    actual.contains_links?
  end
end

describe "Parsing links from tweets" do
  let(:parser) { VegasFS::Parsers::Link.new(tweet) }

  describe "with links" do
    let(:tweet) { "Factory Girl's new look http://bit.ly/mJtiSl"}

    it "should detect there is a link" do
      parser.should contain_links
    end

    it "should download the link" do
      stub_request(:get, 'bit.ly/mJtiSl').to_return(
        :body => "Some html including <em>Factory Girl</em>"
      )
      parser.link_html.should include("Factory Girl")
    end
  end

  describe "without links" do
    let(:tweet) { "This is a tweet. It has no links.Right?"}

    it "should detect there are no links" do
      parser.should_not contain_links
    end
  end
end

