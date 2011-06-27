require 'net/http'
require 'uri'

class VegasFS::Driver
  def self.connect(*args, &blk)
    new(*args, &blk)
  end

  def initialize(opts)
    @host = opts[:host] or raise 'Must specify target host'
    @port = opts[:port] or raise 'Must specify target port'
  end

  def read_file(path)
    with_remote do |http|
      http.get(path)
    end
  end

  alias_method :contents, :read_file

  def write_to(path, str)
    with_remote do |http|
      http.post(path, str)
    end
  end

  protected
  def with_remote(&blk)
    Net::HTTP.start(@host, @port, &blk)
  end
end
