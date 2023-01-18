require "administrate/base_dashboard"

module DiscourseAnnotator
  class CodeDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
        creator: Annotator::UserField,
        project: Field::BelongsTo.with_options(class_name: 'DiscourseAnnotator::Project'),
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
        names: Annotator::HasManyCodeNamesField.with_options(class_name: 'DiscourseAnnotator::CodeName', association_name: 'names'),
        sub_codes: Annotator::HasManySubCodesField.with_options(class_name: 'DiscourseAnnotator::Code', association_name: 'sub_codes'),
    }.freeze

    COLLECTION_ATTRIBUTES = [
        :id,
        :name,
        :creator,
    ].freeze

    SHOW_PAGE_ATTRIBUTES = [
        :id,
        :names,
        :parent,
        :description,
        :creator,
        :created_at,
        :updated_at,
        :sub_codes,
        :annotations,
    ].freeze

    FORM_ATTRIBUTES = [
        :project,
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
