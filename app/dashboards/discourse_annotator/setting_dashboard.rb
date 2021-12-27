require "administrate/base_dashboard"

module DiscourseAnnotator
  class SettingDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
      id: Field::Number,
      public_codes_list_api_endpoint: Field::Boolean,
    }.freeze

    SHOW_PAGE_ATTRIBUTES = [
      :public_codes_list_api_endpoint,
    ].freeze

    FORM_ATTRIBUTES = [
      :public_codes_list_api_endpoint,
    ].freeze

    def display_resource(code_name)
      "Settings"
    end

  end
end
