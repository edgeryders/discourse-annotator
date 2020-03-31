module AnnotatorStore

  # Acts as a cache table to handle localized tag-paths and tag-names.
  # Required to make fast autocomplete searches with localized paths possible.
  class LocalizedTag < ActiveRecord::Base

    delegate :locale, to: :language


    # Associations
    belongs_to :tag
    belongs_to :language

    # Validations
    validates :name, presence: true
    validates :path, presence: true
    validates :tag, presence: true
    validates :language, presence: true

    # Callbacks
    before_validation do
      self.name = tag.name_for_language(language)
      self.path = tag.path.map {|t| t.name_for_language(language)}.join(' → ')
    end


    # --- Class Methods --- #

    def self.create_or_update_all
      AnnotatorStore::Language.all.each do |language|
        AnnotatorStore::Tag.find_each do |tag|
          AnnotatorStore::LocalizedTag.find_or_create_by!(tag_id: tag.id, language_id: language.id)
        end
      end
    end


    # --- Instance Methods --- #


  end
end