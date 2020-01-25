module CrystalDocs
  class Shards
    Shard = Struct.new(:name, :repository, :created_at, :updated_at, :status, :last_commit_hash)

    def self.all
      Store.all.values
    end

    def self.load_in
      JSON.parse(File.read(DATA_PATH + "/shards.json"), symbolize_names: true)
    end

    def self.add_shard(repository)
      provider, username, shard = repo_to_split(repository)
      # TODO:
      #   Sanitize commands
      _shard = Shard.new
      Store.store(:"#{shard}", _shard)

      _shard.name = shard
      _shard.repository = "https://#{provider}/#{username}/#{shard}"
      _shard.created_at = Time.now.utc
      _shard.updated_at = Time.now.utc
      _shard.status = :queued

      Dir.chdir("data") do
        _shard.status = :building
        system("rm -rf #{shard}") if Dir.exists?("#{shard}")
        ENV["GIT_TERMINAL_PROMPT"] = "0" # Disable cred request
        cloned = system("git clone --quiet --depth 1 --branch master https://#{provider}/#{username}/#{shard}.git")

        if cloned
          _shard.last_commit_hash = "???"

          Dir.chdir("#{shard}") do
            # TODO: Make `crystal docs` ignore shards;
            #   shards with external dependencies fail to build docs.
            downloaded_unneed_shards = system("shards install --production")
            docs_built = system("crystal docs --output=\"#{DOCS_PATH}/#{provider}/#{username}/#{shard}\"")

            if docs_built
              _shard.status = :built
            else
              _shard.status = :failed
            end
          end
        else
          _shard.status = :failed
        end
      end
    end

    def self.known_shard?(shard)
      get(shard)
    end

    def self.path_to(shard)
      _shard = get(shard)
      provider, username, shard = repo_to_split(_shard.repository)
      "/#{provider}/#{username}/#{shard}"
    end

    def self.repo_to_split(repository)
        uri = URI.parse(repository)
        path = uri.path.split("/")

        [ uri.hostname, path[1], path[2] ]
    end

    def self.search(shard)
      all.select { |s| s.name.include?(shard) }
    end

    def self.get(shard)
      all.find { |s| s.name.include?(shard) }
    end

    def self.status_icon(shard_instance)
      case shard_instance.status
      when :built
        " 🕮 "
      when :pending
        " 🕐 "
      else
        " ⚠ "
      end
    end
  end
end