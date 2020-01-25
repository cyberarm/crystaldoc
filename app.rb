require "bundler"
Bundler.setup(:default)
Bundler.require(:default)

require_relative "lib/web"
require_relative "lib/shards"
require_relative "lib/store"