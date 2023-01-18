require "administrate/base_dashboard"

class DiscourseAnnotator::LanguageDashboard < Administrate::BaseDashboard

  ATTRIBUTE_TYPES = {
    code_names: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    locale: Annotator::LocaleField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    codes_count: Field::Number
  }.freeze

  COLLECTION_ATTRIBUTES = [
    # :code_names,
    # :id,
    :name,
    :locale,
    :codes_count
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    # :code_names,
    :id,
    :name,
    :locale,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    # :code_names,
    :name,
    :locale,
  ].freeze

  def display_resource(language)
    "#{language.name}"
  end

end
