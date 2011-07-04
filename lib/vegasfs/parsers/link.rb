require 'net/http'
require 'uri'

module VegasFS::Parsers
  
  ##
  # @author Lou Scoras <ljsc@gwu.edu>
  # 
  # Parser to scan tweets for links. Instances of this class search the body of
  # tweets for any links. This will find any link, although images are intended
  # to be handled seperately. See VegasFS::Parsers::Image.
  #
  # In addition to detecting whether links exist, the links can be downloaded
  # and the html representations can be returned. This might be of limited
  # usability, however, since most sites use relative urls for assets, but it
  # might be helpful to develeopers.
  #
  class Link

    ##
    # Create a new Link parser.
    # @param [String] tweet The body of the tweet to parse.
    #
    def initialize(tweet)
      match = tweet.match %r{(?:http://)[\w.]+.(?:ly|com|net|us|org)/\S*}

      if match
        @url = match.to_s
      else
        @url = nil
      end
    end

    ##
    # Indicates whether or not any links could be found in the body of the
    # tweet.
    #
    def contains_links?
      !@url.nil?
    end

    ##
    # Downloads the first url from the body of the tweet. Follows any redirects,
    # as most urls on twitter are served from url shortening services.
    # @return [String] the html source from the embedded link.
    #
    def link_html
      uri = URI.parse(@url)

      response = Net::HTTP.start(uri.host) do |http|
        http.get(uri.to_s)
      end

      response = follow_redirects(response)

      response.body
    end
    
    def follow_redirects(response)
      if response.code.to_s =~ /\A3\d\d/
        uri = URI.parse(response['Location'])
        response = Net::HTTP.start(uri.host) do |http|
          http.get(uri.to_s)
        end

        follow_redirects(response)
      else
        response
      end
    end
  end
end
