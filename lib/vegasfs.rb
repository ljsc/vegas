require 'bundler'

Bundler.require(:default)

module VegasFS
end

require 'vegasfs/driver'
require 'vegasfs/router'
require 'vegasfs/parsers/image'
require 'vegasfs/parsers/link'
