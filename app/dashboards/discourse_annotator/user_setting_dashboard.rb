require "administrate/base_dashboard"

module DiscourseAnnotator
  class UserSettingDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
      discourse_user: Field::BelongsTo.with_options(class_name: '::User', order: 'username ASC', scope: -> { ::User.annotators }),
      language: Annotator::LanguageField.with_options(class_name: 'DiscourseAnnotator::Language'),
      id: Field::Number,
    }.freeze

    COLLECTION_ATTRIBUTES = [
      :discourse_user,
      :language,
      #:id,
    ].freeze

    SHOW_PAGE_ATTRIBUTES = [
      :discourse_user,
      :language,
      :id,
    ].freeze

    FORM_ATTRIBUTES = [
      :discourse_user,
      :language,
    ].freeze

    def display_resource(code_name)
      "User Settings"
    end

  end
end