require "administrate/base_dashboard"

module DiscourseAnnotator
  class CodeDashboard < Administrate::BaseDashboard

    # ATTRIBUTE_TYPES
    # a hash that describes the type of each of the model's fields.
    #
    # Each different type represents an Administrate::Field object,
    # which determines how the attribute is displayed
    # on pages throughout the dashboard.
    ATTRIBUTE_TYPES = {
        creator: Annotator::UserField,
        parent: Annotator::ParentCodeField.with_options(class_name: 'DiscourseAnnotator::Code'),
        merge_into_code: Annotator::MergeCodeField.with_options(class_name: 'DiscourseAnnotator::Code'),
        id: Field::Number,
        name: Field::String,
        description: Field::Text,
        creator_id: Field::Number,
        parent_id: Field::Number,
        created_at: Field::DateTime,
        updated_at: Field::DateTime,
        annotations: Annotator::HasManyAnnotationsField.with_options(class_name: 'DiscourseAnnotator::Annotation', limit: 100),
        names: Field::NestedHasMany.with_options(class_name: 'DiscourseAnnotator::CodeName', association_name: 'names', skip: :code),
        localized_codes: Field::NestedHasMany.with_options(class_name: 'DiscourseAnnotator::LocalizedCode', skip: :code, limit: 100),
    }.freeze

    # COLLECTION_ATTRIBUTES
    # an array of attributes that will be displayed on the model's index page.
    #
    # By default, it's limited to four items to reduce clutter on index pages.
    # Feel free to add, remove, or rearrange items.
    COLLECTION_ATTRIBUTES = [
        :id,
        :name,
        :creator,
    ].freeze

    # SHOW_PAGE_ATTRIBUTES
    # an array of attributes that will be displayed on the model's show page.
    SHOW_PAGE_ATTRIBUTES = [
        :id,
        :names,
        :parent,
        :description,
        :creator,
        :created_at,
        :updated_at,
        :annotations,
        :localized_codes,
    ].freeze

    # FORM_ATTRIBUTES
    # an array of attributes that will be displayed
    # on the model's form (`new` and `edit`) pages.
    FORM_ATTRIBUTES = [
        :names,
        :parent,
        :description,
        :creator,
        :merge_into_code
    ].freeze

    # Overwrite this method to customize how codes are displayed
    # across all pages of the admin dashboard.
    def display_resource(code)
      "Code \"#{code.localized_name}\""
    end

  end
end
