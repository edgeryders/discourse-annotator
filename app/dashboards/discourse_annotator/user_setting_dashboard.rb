require "administrate/base_dashboard"

module DiscourseAnnotator
  class UserSettingDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
      discourse_user: Field::BelongsTo.with_options(class_name: '::User', order: 'username ASC', scope: -> { ::User.annotators }),
      discourse_tag: Annotator::DiscourseTagField.with_options(class_name: '::Tag', order: 'name ASC', scope: -> { ::Tag.where('lower(name) LIKE ?', "ethno-%") }),
      propose_codes_from_users: Annotator::ProposeCodesFromUsersField,
      language: Annotator::LanguageField.with_options(class_name: 'DiscourseAnnotator::Language'),
      id: Field::Number,
    }.freeze

    COLLECTION_ATTRIBUTES = [
      #:id,
      :discourse_user,
      :discourse_tag,
      :propose_codes_from_users,
      :language,
    ].freeze

    SHOW_PAGE_ATTRIBUTES = [
      :discourse_user,
      :discourse_tag,
      :propose_codes_from_users,
      :language,
      :id,
    ].freeze

    FORM_ATTRIBUTES = [
      :discourse_user,
      :discourse_tag,
      :propose_codes_from_users,
      :language,
    ].freeze

    def display_resource(code_name)
      "User Settings"
    end

  end
end