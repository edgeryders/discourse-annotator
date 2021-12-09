require "administrate/base_dashboard"

module AnnotatorStore
  class AnnotationDashboard < Administrate::BaseDashboard
    # ATTRIBUTE_TYPES
    # a hash that describes the type of each of the model's fields.
    #
    # Each different type represents an Administrate::Field object,
    # which determines how the attribute is displayed
    # on pages throughout the dashboard.
    ATTRIBUTE_TYPES = {
      creator: Annotator::UserField,
      tag: Annotator::TagField.with_options(class_name: 'AnnotatorStore::Tag'),
      id: Field::Number,
      uri: Field::String,
      type: Annotator::AnnotationTypeField,
      tag_id: Field::Number,
      creator_id: Field::Number,
      created_at: Field::DateTime,
      updated_at: Field::DateTime,
      topic: Annotator::TopicField,
      src: Field::String,
      code: Annotator::TagField.with_options(class_name: 'AnnotatorStore::Tag'), # quickfix. See: https://github.com/thoughtbot/administrate/issues/1681
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

    # COLLECTION_ATTRIBUTES
    # an array of attributes that will be displayed on the model's index page.
    #
    # By default, it's limited to four items to reduce clutter on index pages.
    # Feel free to add, remove, or rearrange items.
    COLLECTION_ATTRIBUTES = [
      :id,
      :type,
      :tag,
      :text,
      :quote,
      :creator,
      :created_at
    ].freeze

    # SHOW_PAGE_ATTRIBUTES
    # an array of attributes that will be displayed on the model's show page.
    SHOW_PAGE_ATTRIBUTES = [] # Overwritten in subclasses.

    # FORM_ATTRIBUTES
    # an array of attributes that will be displayed
    # on the model's form (`new` and `edit`) pages.
    FORM_ATTRIBUTES = [
      # :creator,
      :text,
      :tag
    ].freeze

    # Overwrite this method to customize how tags are displayed
    # across all pages of the admin dashboard.
    def display_resource(tag)
      "Annotation ##{tag.id}"
    end


  end
end
