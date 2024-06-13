require 'administrate/field/belongs_to_search'
require "administrate/field/nested_has_many"


module DiscourseAnnotator
  class Engine < ::Rails::Engine
    isolate_namespace DiscourseAnnotator


    # https://www.reddit.com/r/rails/comments/6jyrq3/how_can_i_change_a_model_from_main_app_when_i_am/
    config.to_prepare do
      Topic.send :include, TopicAnnotatable
      Post.send :include, PostAnnotatable
      User.send :include, UserAnnotatable
      PostRevision.send :include, PostRevisionAnnotatable
    end


    config.generators do |g|
      g.integration_tool :rspec
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end


  end
end