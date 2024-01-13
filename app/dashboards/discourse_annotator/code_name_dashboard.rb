require "administrate/base_dashboard"

module DiscourseAnnotator
  class CodeNameDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
      code: Field::BelongsTo,
      language: Field::BelongsTo,
      id: Field::Number,
      name: Field::String,
      created_at: Field::DateTime,
      updated_at: Field::DateTime,
    }.freeze

    COLLECTION_ATTRIBUTES = [
      #:id,
      :name,
      :language,
    ].freeze

    SHOW_PAGE_ATTRIBUTES = [
      :code,
      :language,
      :id,
      :name,
      :created_at,
      :updated_at,
    ].freeze

    FORM_ATTRIBUTES = [
      :name,
      :language,
    ].freeze

    def display_resource(code_name)
      "Code Name"
    end

  end
end