require 'net/http'

module VegasFS::Parsers
  class Image
    attr_reader :url

    SERVICE_HOST = 'yfrog.com'

    def initialize(tweet)
      if m = tweet.match( %r|(?:http://)?#{SERVICE_HOST}/\w+| )
        @url = m.to_s
      else
        @url = nil
      end
    end

    def contains_images?
      !@url.nil?
    end

    def contains_jpeg?
      contains_images? and @url =~ /j\z/i
    end

    def contains_png?
      contains_images? and @url =~ /p\z/i
    end

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
