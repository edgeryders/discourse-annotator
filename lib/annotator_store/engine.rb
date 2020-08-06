module AnnotatorStore
  class Engine < ::Rails::Engine
    isolate_namespace AnnotatorStore


    # https://www.reddit.com/r/rails/comments/6jyrq3/how_can_i_change_a_model_from_main_app_when_i_am/
    config.to_prepare do
      Topic.send :include, TopicAnnotatable
      Post.send :include, PostAnnotatable
      User.send :include, UserAnnotatable
    end


    config.generators do |g|
      g.integration_tool :rspec
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end


    # https://github.com/rails/sprockets/issues/542
    initializer "annotator_store.assets.precompile" do |app|
      app.config.assets.precompile << "annotator_store.js"
      app.config.assets.precompile << "annotator_store.css"
    end


  end

end
