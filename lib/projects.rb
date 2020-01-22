module CrystalDocs
  class Projects
    DATA_PATH = File.expand_path("../data", __dir__)
    DOCS_PATH = File.expand_path("../public", __dir__)

    Project = Struct.new(:name, :repository)

    def self.all
      [
        Project.new("gosu.cr", "https://github.com/gosu/gosu.cr"),
        Project.new("kemal", "https://github.com/kemalcr/kemal"),
      ]
    end

    def self.add_project(provider, username, project)
      Dir.chdir("data") do
        cloned = system("git clone --depth 1 --branch master https://#{provider}/#{username}/#{project}.git")

        if cloned
          Dir.chdir("#{project}") do
            # TODO: Make `crystal docs` ignore shards;
            #   shards with external dependencies fail to build docs.
            system("crystal docs --output=\"../../public/#{provider}/#{username}/#{project}\"")
          end
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