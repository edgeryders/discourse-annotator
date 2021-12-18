module DiscourseAnnotator
  class UserSetting < ActiveRecord::Base

    # Associations
    belongs_to :discourse_user, class_name: '::User'
    belongs_to :discourse_tag, class_name: '::Tag'
    belongs_to :language

    # Validations
    validates :discourse_user, presence: true, uniqueness: true
    validates :language, presence: true



    def self.language_for_user(user)
      DiscourseAnnotator::UserSetting.find_by(discourse_user_id: user.id)&.language ||
          DiscourseAnnotator::UserSetting.create!(discourse_user_id: user.id, language_id: DiscourseAnnotator::Language.english.id)
    end


  end
end
