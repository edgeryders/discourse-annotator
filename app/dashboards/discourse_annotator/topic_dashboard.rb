require 'administrate/base_dashboard'

module DiscourseAnnotator

  class TopicDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
      id: Field::Number,
      title: Field::String.with_options(truncate: nil),
      created_at: Field::DateTime,
      updated_at: Field::DateTime,
      user_annotations_count: Field::Number,
      annotations_count: Field::Number
    }.freeze

    COLLECTION_ATTRIBUTES = [
      :id,
      :title,
      :user_annotations_count,
      :annotations_count
    ].freeze

    SHOW_PAGE_ATTRIBUTES = [
    ].freeze

  end
end