require 'net/http'

##
# Namespace for parsers for extracting asset information from tweets.
#
module VegasFS::Parsers

  ##
  # @author Lou Scoras <ljsc@gwu.edu>
  #
  # Parser to search through the body of tweets to find urls which lead to
  # images. We support both +.jpeg+ and +.png+ file formats hosted at the
  # yfrog.com service. The Image parser class can be used to check for the
  # existance of images inside of tweets, and also to get the image data
  # downloaded from the remote host.
  #
  class Image
    
    ##
    # The url where the image referenced in the tweet lives. +nil+ if there is
    # no image referenced from the tweet.
    #
    attr_reader :url

    ##
    # Other hosts may be supported later, but for now images are only detected
    # if they are hosted on yfrog.
    #
    SERVICE_HOST = 'yfrog.com'

    ##
    # The parser looks for the image in the tweet at the time of instanciation.
    # @param [String] the body text of the tweet to parse.
    #
    def initialize(tweet)
      if m = tweet.match( %r|(?:http://)?#{SERVICE_HOST}/\w+| )
        @url = m.to_s
      else
        @url = nil
      end
    end

    ##
    # Indicates whether there are any image urls inside of the tweet body.
    #
    def contains_images?
      !@url.nil?
    end

    ##
    # Detects from the image url whether or not it is a +.jpeg+ file or not.
    #
    def contains_jpeg?
      contains_images? and @url =~ /j\z/i
    end

    ##
    # Detects from the image url whether or not it is a +.png+ file or not.
    #
    def contains_png?
      contains_images? and @url =~ /p\z/i
    end

    ##
    # Downloads the image data from the url extracted from the tweet.
    # @return [String] The binary image data
    #
    def image_data
      response = nil

      Net::HTTP.start(SERVICE_HOST) do |http|
        response = http.get(URI.parse(@url).path + ':medium')

        if response.code.to_s =~ /\A3\d\d/
          new_location = URI.parse(response['Location'])
          Net::HTTP.start(new_location.host) do |http|
            response = http.get(new_location.path + '?' + new_location.query)
          end
        end
      end

      response.body
    end
  end
end
