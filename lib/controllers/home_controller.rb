module CrystalDocs
  class Web < Sinatra::Application
    get "/?" do
      @shards = Shards.all.sort_by { |s| s.updated_at }.take(10).reverse

      slim :"home/index"
    end

    get "/about/?" do
      slim :"home/about"
    end

    get "/css/application.css" do
      expires 60 * 60 * 24 * 7, :public
      content_type "text/css"

      SassC::Engine.new(
        SassC::Sass2Scss.convert(File.read("views/application.sass")),
        style: :expanded
      ).render
    end
  end
end