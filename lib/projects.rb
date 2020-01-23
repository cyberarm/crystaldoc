module CrystalDocs
  class Projects
    DATA_PATH = File.expand_path("../data", __dir__)
    DOCS_PATH = File.expand_path("../public", __dir__)

    @@projects = []

    Project = Struct.new(:name, :repository, :created_at, :updated_at, :status, :last_commit_hash)

    def self.all
      @@projects.select { |s| s.status == :built }
    end

    def self.load_in
      JSON.parse(File.read(DATA_PATH + "/projects.json"), symbolize_names: true)
    end

    def self.add_project(provider, username, project)
      # TODO:
      #   Sanitize commands
      _project = Project.new
      @@projects << _project

      _project.name = project
      _project.repository = "https://#{provider}/#{username}/#{project}"
      _project.created_at = Time.now.utc
      _project.updated_at = Time.now.utc
      _project.status = :queued

      Dir.chdir("data") do
        _project.status = :building
        system("rm -rf #{project}") if Dir.exists?("#{project}")
        cloned = system("git clone --depth 1 --branch master https://#{provider}/#{username}/#{project}.git")

        if cloned
          _project.last_commit_hash = "???"

          Dir.chdir("#{project}") do
            # TODO: Make `crystal docs` ignore shards;
            #   shards with external dependencies fail to build docs.
            docs_built = system("crystal docs --output=\"#{DOCS_PATH}/#{provider}/#{username}/#{project}\"")

            if docs_built
              _project.status = :built
            else
              _project.status = :failed
            end
          end
        else
          _project.status = :failed
        end
      end
    end

    def self.known_project?(provider, username, project)
      false
    end

    def self.path_to(provider, username, project)
      "/#{provider}/#{username}/#{project}"
    end

    def self.repo_to_split(repository)
        uri = URI.parse(repository)
        path = uri.path.split("/")

        [ uri.hostname, path[1], path[2] ]
    end

    def self.search(shard)
      Projects.all.select { |s| s.name.include?(shard) }
    end

    def self.get(shard)
      Projects.all.find { |s| s.name.include?(shard) }
    end
  end
end