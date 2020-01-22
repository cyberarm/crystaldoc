module CrystalDocs
  class Web < Sinatra::Application
    namespace "/shards/?" do

      get "/?" do
        @projects = Projects.all

        slim :"shards/index"
      end

      get "/:shard/?" do
        @project = Projects.get( params[:shard] )

        slim :"shards/show"
      end
    end

    get "/add/?" do
      slim :"shards/add"
    end

    post "/add/?" do
      provider, username, project = Projects.repo_to_split(params[:repository])

      unless Projects.known_project?(provider, username, project)
        Projects.add_project(provider, username, project)
      end

      redirect Projects.path_to(provider, username, project)
    end

    get "/search/?" do
      @found_projects = Projects.search( params[:q] )

      slim :"shards/search"
    end

    get "/:provider/:username/:project" do
      "No such project"
    end
  end
end