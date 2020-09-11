module AnnotatorStore
  class Language < ActiveRecord::Base

    # Associations
    has_many :tag_names, dependent: :restrict_with_exception
    has_many :localized_tags, dependent: :delete_all

    # Validations
    validates :name, presence: true, uniqueness: {case_sensitive: false}
    validates :locale, presence: true, uniqueness: {case_sensitive: false}

    # Callbacks
    after_create :create_localized_tags

    # Scopes
    scope :with_codes_count, -> {
      select('annotator_store_languages.*, count(annotator_store_tag_names.id) AS codes_count').left_joins(:tag_names).group('annotator_store_languages.id')
    }


    # --- Class Methods --- #

    def self.english
      AnnotatorStore::Language.create_with(name: 'English').find_or_create_by(locale: 'en')
    end


    # --- Instance Methods --- #

    private

    def create_localized_tags
      ActiveRecord::Base.connection.execute("
        INSERT INTO annotator_store_localized_tags(name, path, tag_id, language_id, created_at, updated_at)
        SELECT name, path, tag_id, #{id}, now(), now() FROM annotator_store_localized_tags
          WHERE language_id = #{AnnotatorStore::Language.english.id};
      ")
    end


  end
end
