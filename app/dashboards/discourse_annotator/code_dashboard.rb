require "administrate/base_dashboard"

module DiscourseAnnotator
  class CodeDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
        creator: Annotator::UserField,
        project: Field::BelongsTo,
        parent: Field::BelongsTo.with_options(class_name: 'DiscourseAnnotator::Code'),
        parent_id: Annotator::ParentCodeField,
        merge_into_code_id: Annotator::MergeCodeField,
        id: Field::Number,
        name: Field::String,
        description: Field::Text,
        creator_id: Field::Number,
        created_at: Field::DateTime,
        updated_at: Field::DateTime,
        annotations: Annotator::HasManyAnnotationsField.with_options(collection_attributes: [:id, :topic_id_and_post_id, :type, :text, :quote, :creator, :created_at], limit: 100),
        names: Annotator::HasManyCodeNamesField.with_options(association_name: 'names', skip: :code),
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
        :parent_id,
        :description,
        :creator,
        :merge_into_code_id
    ].freeze

    # Overwrite this method to customize how codes are displayed
    # across all pages of the admin dashboard.
    def display_resource(code)
      "Code \"#{code.localized_name}\""
    end

  end
end
