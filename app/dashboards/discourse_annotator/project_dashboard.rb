require "administrate/base_dashboard"

module DiscourseAnnotator
  class ProjectDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
        id: Field::Number,
        name: Field::String,
        created_at: Field::DateTime,
        updated_at: Field::DateTime,
        codes_count: Field::Number
    }.freeze

    COLLECTION_ATTRIBUTES = [
        :id,
        :name,
        :codes_count,
    ].freeze

    SHOW_PAGE_ATTRIBUTES = [
        :id,
        :name,
        :created_at,
        :updated_at,
    ].freeze

    FORM_ATTRIBUTES = [
        :name,
    ].freeze

    def display_resource(project)
      "Project \"#{project.name}\""
    end

  end
end
