require "administrate/base_dashboard"

module DiscourseAnnotator
  class AnnotationDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
      creator: Annotator::UserField,
      code: Annotator::CodeField.with_options(class_name: 'DiscourseAnnotator::Code'), # quickfix. See: https://github.com/thoughtbot/administrate/issues/1681
      id: Field::Number,
      uri: Field::String,
      type: Annotator::AnnotationTypeField,
      code_id: Field::Number,
      creator_id: Field::Number,
      created_at: Field::DateTime,
      updated_at: Field::DateTime,
      topic: Annotator::TopicField,
      src: Field::String,
      topic_id_and_post_id: Field::String.with_options(searchable: false),
      # TextAnnotation
      text: Annotator::TruncatedTextField.with_options(searchable: true),
      quote: Annotator::AnnotationQuoteField.with_options(searchable: true),
      version: Field::String,
      # VideoAnnotation
      container: Field::String,
      ext: Field::String,
      start: Field::String,
      end: Field::String,
      # Image Annotation
      shape: Field::String,
      units: Field::String,
      geometry: Field::String,
    }.freeze

    COLLECTION_ATTRIBUTES = [
      :id,
      :topic_id_and_post_id,
      :type,
      :code,
      :text,
      :quote,
      :creator,
      :created_at
    ].freeze

    SHOW_PAGE_ATTRIBUTES = [] # Overwritten in subclasses.

    FORM_ATTRIBUTES = [
      # :creator,
      :text,
      :code
    ].freeze

    # Overwrite this method to customize how codes are displayed
    # across all pages of the admin dashboard.
    def display_resource(code)
      "Annotation ##{code.id}"
    end


  end
end
