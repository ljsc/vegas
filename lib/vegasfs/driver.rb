require 'net/http'
require 'uri'
require 'json'

class VegasFS::Driver
  def self.connect(*args, &blk)
    new(*args, &blk)
  end

  def initialize(opts)
    @host = opts[:host] or raise 'Must specify target host'
    @port = opts[:port] or raise 'Must specify target port'
  end

  def read_file(path)
    response = with_remote do |http|
      http.get(path)
    end
    response.body
  end

  def directory?(path)
    path !~ /[.]txt\z/
  end

  def file?(path)
    !directory?(path)
  end

  def contents(path)
    response = with_remote do |http|
      http.get(path)
    end
    json = JSON.parse(response.body)
    json[json.keys[0]]
  rescue JSON::ParserError
    []
  end

  def write_to(path, str)
    with_remote do |http|
      http.post(path, str)
    end
  end

  def size(path)
    response = with_remote do |http|
      http.head(path)
    end
    response['Content-Length'].to_i
  end

  def delete(path)
    with_remote do |http|
      http.delete(path)
    end
  end

  protected
  def with_remote(&blk)
    Net::HTTP.start(@host, @port, &blk)
  end
end
