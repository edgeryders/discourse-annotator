require "administrate/base_dashboard"

module DiscourseAnnotator
  class UserSettingDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
      discourse_user: Annotator::UserField.with_options(class_name: '::User', order: 'username ASC', scope: -> { ::User.annotators }),
      language: Annotator::LanguageField,
      id: Field::Number,
    }.freeze

    COLLECTION_ATTRIBUTES = [
      :id,
      :discourse_user,
      :language,
    ].freeze

    SHOW_PAGE_ATTRIBUTES = [
      :id,
      :discourse_user,
      :language,
    ].freeze

    FORM_ATTRIBUTES = [
      # :discourse_user,
      :language,
    ].freeze

    def display_resource(user_settings)
      "User Settings for user #{user_settings.discourse_user.display_name}"
    end

  end
end