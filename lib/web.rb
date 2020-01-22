module CrystalDocs
  class Web < Sinatra::Application
    set :root, Dir.pwd
    set :sessions, true
    set :logging, true

    # register Sinatra::Flash
    register Sinatra::Namespace

    helpers Sinatra::ContentFor
    helpers Sinatra::Cookies

    configure :development do
      register Sinatra::Reloader
    end
  end
end

require_relative "controllers/home"
require_relative "controllers/shards"