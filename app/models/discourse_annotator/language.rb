module DiscourseAnnotator
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
      select('discourse_annotator_languages.*, count(discourse_annotator_tag_names.id) AS codes_count').left_joins(:tag_names).group('discourse_annotator_languages.id')
    }


    # --- Class Methods --- #

    def self.english
      DiscourseAnnotator::Language.create_with(name: 'English').find_or_create_by(locale: 'en')
    end


    # --- Instance Methods --- #

    private

    def create_localized_tags
      ActiveRecord::Base.connection.execute("
        INSERT INTO discourse_annotator_localized_tags(name, path, tag_id, language_id, created_at, updated_at)
        SELECT name, path, tag_id, #{id}, now(), now() FROM discourse_annotator_localized_tags
          WHERE language_id = #{DiscourseAnnotator::Language.english.id};
      ")
    end


  end
end
