require 'net/http'
require 'uri'

module VegasFS::Parsers
  class Link
    def initialize(tweet)
      match = tweet.match %r{(?:http://)[\w.]+.(?:ly|com|net|us|org)/\S*}

      if match
        @url = match.to_s
      else
        @url = nil
      end
    end

    def contains_links?
      !@url.nil?
    end

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
