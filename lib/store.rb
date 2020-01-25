module CrystalDocs
  class Store
    STORE_FILE = CrystalDocs::DATA_PATH + "/shards.json"
    @@store = {}

    def self.get(key)
      @@store.dig(key)
    end

    def self.store(key, value)
      @@store[key] = value
    end

    def self.dump(store_file = STORE_FILE)
      File.write
    end

    def self.load(store_file = STORE_FILE)
      JSON.parse(File.read(STORE_FILE), symbolize_names: true)
    end

    def self.all
      @@store
    end
  end
end