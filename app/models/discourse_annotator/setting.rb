module DiscourseAnnotator
  class Setting < ActiveRecord::Base


    def self.instance
      DiscourseAnnotator::Setting.first || DiscourseAnnotator::Setting.create!
    end

  end
end