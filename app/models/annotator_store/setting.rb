module AnnotatorStore
  class Setting < ActiveRecord::Base


    def self.instance
      AnnotatorStore::Setting.first || AnnotatorStore::Setting.create!
    end

  end
end