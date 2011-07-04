require 'net/http'
require 'uri'
require 'json'

##
# @author Lou Scoras <ljsc@gwu.edu>
#
# This class implements the Fuse API end points required to get the Vegas file
# system up and running. An instance can be passed to the +FuseFS.set_root+
# method to mount the system.
#
# All +path+ parameters should be specified as realtive to the directory the
# system is mounted against. The should all begin with a "/" character.
#
# For example, if vegas is mounted at +/home/user1/t+, then
#     $ ls /home/user1/t/tweet/32.txt
# would invoke {#read_file} on +/tweet/32.txt+.
#
class VegasFS::Driver

  ##
  # Connect is an alias for #new.
  # @param [Array] args all arguments are passed to the constructor. See {#initialze}
  #
  def self.connect(*args, &blk)
    new(*args, &blk)
  end

  ##
  # Creates a new instance of the driver.
  # @param [Hash] opts Connection configuration options
  # @option opts [String] :host Host on which to connect to the router
  # @option opts [String] :port Port to connect on
  #
  def initialize(opts)
    @host = opts[:host] or raise 'Must specify target host'
    @port = opts[:port] or raise 'Must specify target port'
  end

  ##
  # Read the contents at a given path. Sends a +GET+ request to the Vegas
  # router.
  # @param [String] path The path to the requested resource
  # @return [String] The data representation of the resource at +path+
  #
  def read_file(path)
    response = with_remote do |http|
      http.get(path)
    end
    response.body
  end

  ##
  # Check whether the resource is a directory or not.
  # @param [String] path Resource to check
  # @return [true, false] Whether or not the resource is a directory
  #
  def directory?(path)
    without_extension?(path) && exists?(path)
  end

  ##
  # See #directory?
  #
  def file?(path)
    !without_extension?(path) && exists?(path)
  end

  ##
  # Check whether the resource should exist. Obviously, for a resource to be
  # either a {#directory?} or {#file?} it must first {#exists?}.
  # @param [String] path The path of the resource to check
  # @return [true, false] Whether or not the resource exists
  #
  def exists?(path)
    response = with_remote do |http|
      http.head(path)
    end
    response.code !~ /\A4/
  end

  ##
  # List the contents of a directory. The resource must be a {#directory?}
  # @param [String] path The path to the directory resource to list
  # @note This method expects a JSON representation of the directory. It should
  #   be a Hash containing a single key, whose value is a list of other resources
  #   within that directory.
  # @return [Array<String>] A list of resources contained in the directory.
  #
  def contents(path)
    response = with_remote do |http|
      http.get(path)
    end
    json = JSON.parse(response.body)
    json[json.keys[0]]
  rescue JSON::ParserError
    []
  end

  ##
  # Writes data to a given resource. Sends a +POST+ request to the Vegas router.
  # @param [String] path Location of the given resource
  # @param [String] str Contains the data to write to the resource.
  # @return [void]
  #
  def write_to(path, str)
    with_remote do |http|
      http.post(path, str)
    end
  end

  ##
  # Query the size of a specified resource. Sends a +HEAD+ request to the Vegas
  # router.
  # @param [String] path The path of the resource to check the size for
  # @return [Int] The size in bytes of the resource.
  #
  def size(path)
    response = with_remote do |http|
      http.head(path)
    end
    response['Content-Length'].to_i
  end

  ##
  # Delete the resource at path. Send a +DELETE+ request to the Vegas router.
  # @param [String] path Path of the resource to delete
  # @return [void]
  #
  def delete(path)
    with_remote do |http|
      http.delete(path)
    end
  end

  protected
  def with_remote(&blk)
    Net::HTTP.start(@host, @port, &blk)
  end

  def without_extension?(path)
    path !~ /[.](?:txt|jpe?g|png|html)\z/
  end

end
