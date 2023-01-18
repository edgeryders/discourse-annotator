require "administrate/base_dashboard"

module DiscourseAnnotator
  class UserSettingDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
      discourse_user: Field::BelongsTo.with_options(class_name: '::User', order: 'username ASC', scope: -> { ::User.annotators }),
      discourse_tag: Annotator::DiscourseTagField.with_options(class_name: '::Tag', order: 'name ASC', scope: -> { ::Tag.where('lower(name) LIKE ?', "ethno-%") }),
      language: Annotator::LanguageField.with_options(class_name: 'DiscourseAnnotator::Language'),
      id: Field::Number,
      # propose_codes_from_users: Annotator::ProposeCodesFromUsersField,
    }.freeze

    COLLECTION_ATTRIBUTES = [
      :discourse_user,
      :language,
      #:id,
      # :discourse_tag,
      # :propose_codes_from_users,
    ].freeze

    SHOW_PAGE_ATTRIBUTES = [
      :discourse_user,
      :language,
      :id,
      # :discourse_tag,
      # :propose_codes_from_users,
    ].freeze

    FORM_ATTRIBUTES = [
      :discourse_user,
      :language,
      # :discourse_tag,
      # :propose_codes_from_users,
    ].freeze

    def display_resource(code_name)
      "User Settings"
    end

  end
end