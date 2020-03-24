module AnnotatorStore
  class LocalizedTag < ActiveRecord::Base

    delegate :locale, to: :language


    # Associations
    belongs_to :tag
    belongs_to :language

    # Validations
    validates :name, presence: true
    validates :path, presence: true, uniqueness: {scope: [:language_id]}
    validates :tag, presence: true
    validates :language, presence: true


    # Callbacks
    before_save do
      self.name = tag.translated_name(language)
      self.path = tag.translated_name_with_path(language)
    end


  end
end
