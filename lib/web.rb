module CrystalDocs
  DATA_PATH = File.expand_path("../data", __dir__)
  DOCS_PATH = File.expand_path("../public", __dir__)

  class Web < Sinatra::Application
    set :server, :puma
    set :root, Dir.pwd
    set :sessions, true
    set :logging, true

    # register Sinatra::Flash
    register Sinatra::Namespace

    helpers Sinatra::ContentFor
    helpers Sinatra::Cookies

    configure :development do
      puts "Using Reloader..."
      require "sinatra/reloader"
      register Sinatra::Reloader
    end
  end
end

require_relative "controllers/home_controller"
require_relative "controllers/shards_controller"