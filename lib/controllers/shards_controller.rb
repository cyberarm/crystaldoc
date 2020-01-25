module CrystalDocs
  class Web < Sinatra::Application
    namespace "/shards/?" do

      get "/?" do
        @shards = Shards.all.sort_by { |s| s.name.downcase }
        if params[:limit]
          @shards = @shards.select { |s| s.name.downcase.start_with?(params[:limit].downcase) }
        end

        slim :"shards/index"
      end

      get "/:shard/?" do
        @shard = Shards.get( params[:shard] )

        if @shard
          if @shard.status == :built
            redirect "#{CrystalDocs::Shards.path_to(@shard.name)}/index.html"
          else
            slim :"shards/docs_pending"
          end
        else
          slim :"shards/no_docs"
        end
      end
    end

    get "/add/?" do
      slim :"shards/add"
    end

    post "/add/?" do
      provider, username, shard = Shards.repo_to_split(params[:repository])

      unless Shards.known_shard?(shard)
        Shards.add_shard(params[:repository])
      end

      redirect "/shards/#{shard}"
    end

    get "/search/?" do
      @found_shards = Shards.search( params[:q] )

      slim :"shards/search"
    end

    # TODO: Support github/gitlab webhooks
    post "/callback/?" do
      pp params
    end
  end
end