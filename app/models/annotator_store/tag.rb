module AnnotatorStore
  class Tag < ActiveRecord::Base

    attr_accessor :merge_tag_id

    # https://github.com/stefankroes/ancestry
    has_ancestry

    # Associations
    belongs_to :creator, class_name: '::User'
    has_many :annotations, dependent: :delete_all
    has_many :names, dependent: :delete_all, class_name: 'TagName'
    has_many :localized_tags, dependent: :delete_all

    accepts_nested_attributes_for :names, allow_destroy: true


    # Validations
    #validates :name, presence: true, uniqueness: {scope: [:ancestry, :creator_id], case_sensitive: false}
    validates :creator, presence: true
    validates :names, length: {minimum: 1, too_short: ": One name is required"}

    # Callbacks
    after_save do
      if merge_tag_id.present?
        t = AnnotatorStore::Tag.find(merge_tag_id)
        t.annotations.update(tag_id: id)
        t.destroy if t.is_childless?
      end
    end

    after_save :update_localized_tags


    # --- Class Finder Methods --- #

    # language:
    def self.with_localized_tags(args = {})
      select("annotator_store_tags.*, annotator_store_localized_tags.name, annotator_store_localized_tags.path AS name_with_path")
          .joins(:localized_tags)
          .where(annotator_store_localized_tags: {language_id: args[:language]})
    end


    # --- Instance Methods --- #

    # Alias. Used by administrate
    def name
      localized_name
    end

    def localized_name(language = nil)
      localized_tags.find_by(language: language || AnnotatorStore::Language.english)&.name
    end

    def localized_name_with_path(language = nil)
      localized_tags.find_by(language: language || AnnotatorStore::Language.english)&.path
    end

    def descendants_annotations_count
      AnnotatorStore::Tag.where(id: descendant_ids).sum(&:annotations_count)
    end

    def update_localized_tags
      AnnotatorStore::Language.all.each do |language|
        lt = AnnotatorStore::LocalizedTag.find_or_create_by!(tag_id: id, language_id: language.id)
        lt.save!
        lt.tag.descendants.each(&:save!)
      end
    end

    def name_for_language(language)
      names.find_by(language_id: language.id)&.name ||
          names.find_by(language_id: AnnotatorStore::Language.english.id)&.name ||
          names.order(created_at: :asc).first&.name
    end


  end
end


# NOTE: No longer in use. A counter_cache column is now used instead.
# def self.with_annotations_count
#   select('annotator_store_tags.*, count(annotator_store_annotations.id) AS annotations_count')
#       .joins('LEFT OUTER JOIN annotator_store_annotations on annotator_store_annotations.tag_id = annotator_store_tags.id')
#       .group('annotator_store_tags.id')
# end


