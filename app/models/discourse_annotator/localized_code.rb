module DiscourseAnnotator

  # Acts as a cache table to handle localized code-paths and code-names.
  # Required to make fast autocomplete searches with localized paths possible.
  class LocalizedCode < ActiveRecord::Base

    delegate :locale, to: :language

    # Associations
    belongs_to :code
    belongs_to :language

    # Validations
    validates :name, presence: true
    validates :path, presence: true
    validates :code, presence: true
    validates :language, presence: true

    # Callbacks
    before_validation do
      self.name = code.name_for_language(language)
      self.path = code.path.map { |t| t.name_for_language(language) }.join(self.class.path_separator)
    end


    # --- Class Methods --- #

    def self.path_separator
      ' → '
    end

    # DiscourseAnnotator::LocalizedCode.create_or_update_all
    def self.create_or_update_all
      DiscourseAnnotator::Code.find_each do |code|
        p "code ##{code.id}..."
        code.update_localized_codes
      end
    end


    # --- Instance Methods --- #


  end
end