module AnnotatorStore
  class TagName < ActiveRecord::Base

    delegate :locale, to: :language

    # Associations
    belongs_to :tag
    belongs_to :language

    # Validations
    validates :name, presence: true
    validates :language, presence: true, uniqueness: {scope: [:tag_id]}
    validates :tag, presence: true

    # Make sure all localized-tags that might use this tag-name as name or in the path are kept up-to-date.
    after_save {tag.update_localized_tags if name_changed? || language_id_changed? }
    after_destroy {tag.update_localized_tags}


  end
end
