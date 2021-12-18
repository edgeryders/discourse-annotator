module DiscourseAnnotator
  class TagName < ActiveRecord::Base

    delegate :locale, to: :language

    # Associations
    belongs_to :tag, inverse_of: :names
    belongs_to :language

    # Validations
    validates :name, presence: true
    validates :language, presence: true, uniqueness: {scope: [:tag_id]}
    validates :tag, presence: true

    # Make sure all localized-tags that might use this tag-name as name or in the path are kept up-to-date.
    after_save { tag.update_localized_tags if name_changed? || language_id_changed? }
    after_destroy { tag.update_localized_tags }

    # Callbacks
    before_validation do
      self.name = name&.strip
    end


  end
end


# Used for debugging to find tag-names without tag (which shall never happen).
# DiscourseAnnotator::TagName.joins("LEFT OUTER JOIN discourse_annotator_tags ON discourse_annotator_tags.id = discourse_annotator_tag_names.tag_id").where(discourse_annotator_tags: {id: nil}).count