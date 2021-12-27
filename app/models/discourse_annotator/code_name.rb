module DiscourseAnnotator
  class CodeName < ActiveRecord::Base

    delegate :locale, to: :language

    # Associations
    belongs_to :code, inverse_of: :names
    belongs_to :language

    # Validations
    validates :name, presence: true
    validates :language, presence: true, uniqueness: {scope: [:code_id]}
    validates :code, presence: true

    # Make sure all localized-codes that might use this tag-name as name or in the path are kept up-to-date.
    after_save { code.update_localized_codes if name_changed? || language_id_changed? }
    after_destroy { code.update_localized_codes }

    # Callbacks
    before_validation do
      self.name = name&.strip
    end


  end
end


# Used for debugging to find code-names without code (which shall never happen).
# DiscourseAnnotator::CodeName.joins("LEFT OUTER JOIN discourse_annotator_codes ON discourse_annotator_codes.id = discourse_annotator_code_names.code_id").where(discourse_annotator_codes: {id: nil}).count