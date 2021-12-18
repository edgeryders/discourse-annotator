require "administrate/base_dashboard"

module DiscourseAnnotator
  class LocalizedTagDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
        id: Field::Number,
        name: Field::String,
        path: Field::String,
        language: Field::BelongsTo.with_options(class_name: 'DiscourseAnnotator::Language'),
    }.freeze

    COLLECTION_ATTRIBUTES = [:id, :name, :path, :language].freeze

    SHOW_PAGE_ATTRIBUTES = [].freeze

    FORM_ATTRIBUTES = [].freeze

    # Overwrite this method to customize how tags are displayed
    # across all pages of the admin dashboard.
    def display_resource(tag)
      "Localized Code \"#{tag.localized_name}\""
    end

  end
end
