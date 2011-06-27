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
    response = Net::HTTP.get(URI.parse("http://#@host:#@port#{path}"))
  end
end
