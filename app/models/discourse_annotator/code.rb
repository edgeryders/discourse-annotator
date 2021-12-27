require 'deep_cloneable'

module DiscourseAnnotator
  class Code < ActiveRecord::Base

    attr_accessor :merge_into_code
    attr_accessor :merge_into_code_id

    # https://github.com/stefankroes/ancestry
    has_ancestry orphan_strategy: :adopt

    # Associations
    belongs_to :creator, class_name: '::User'
    has_many :annotations, dependent: :destroy
    has_many :names, dependent: :delete_all, class_name: 'CodeName', inverse_of: :code
    has_many :localized_codes, dependent: :delete_all

    accepts_nested_attributes_for :names, allow_destroy: true, reject_if: proc { |attributes| attributes['name'].blank? }
    validates_associated :names

    # Validations
    # validates :name, presence: true, uniqueness: {scope: [:ancestry, :creator_id], case_sensitive: false}
    validates :creator, presence: true
    validates :names, length: { minimum: 1, too_short: ": One name is required" }

    after_save :update_localized_codes

    # --- Class Finder Methods --- #

    # language:
    def self.with_localized_codes(args = {})
      select("discourse_annotator_codes.*, discourse_annotator_localized_codes.name, discourse_annotator_localized_codes.path AS name_with_path")
        .joins(:localized_codes)
        .where(discourse_annotator_localized_codes: { language_id: args[:language] })
    end

    # See: https://github.com/edgeryders/discourse-annotator/issues/200
    def self.with_localized_path
      select("discourse_annotator_codes.*, discourse_annotator_localized_codes.name, discourse_annotator_localized_codes.path AS name_with_path")
        .joins(:localized_codes)
        .group(%w[discourse_annotator_codes.id discourse_annotator_localized_codes.name discourse_annotator_localized_codes.path])
    end

    def self.without_names
      joins('LEFT OUTER JOIN discourse_annotator_code_names ON discourse_annotator_code_names.code_id = discourse_annotator_codes.id')
        .where('discourse_annotator_code_names.code_id IS NULL')
    end

    # --- Class Methods --- #

    # DiscourseAnnotator::Code.fix_annotations_count
    def self.fix_annotations_count
      ActiveRecord::Base.connection.execute <<-SQL.squish
        UPDATE discourse_annotator_codes
        SET annotations_count = (SELECT count(1)
          FROM discourse_annotator_annotations
          WHERE discourse_annotator_annotations.code_id = discourse_annotator_codes.id)
      SQL
    end

    # --- Instance Methods --- #

    # Alias. Used by administrate
    def name
      localized_name
    end

    def localized_name(language = nil)
      localized_codes.find_by(language: language || DiscourseAnnotator::Language.english)&.name
    end

    def localized_name_with_path(language = nil)
      localized_codes.find_by(language: language || DiscourseAnnotator::Language.english)&.path
    end

    def descendants_annotations_count
      DiscourseAnnotator::Code.where(id: descendant_ids).sum(&:annotations_count)
    end

    def update_localized_codes
      DiscourseAnnotator::Language.all.each do |language|
        lc = DiscourseAnnotator::LocalizedCode.find_or_create_by!(code_id: id, language_id: language.id)
        lc.save!
        lc.code.descendants.each(&:save!)
      end
    end

    def name_for_language(language)
      names.find_by(language_id: language.id)&.name ||
        names.find_by(language_id: DiscourseAnnotator::Language.english.id)&.name ||
        names.order(created_at: :asc).first&.name
    end

    def copy
      # https://github.com/moiristo/deep_cloneable
      new = deep_clone include: [:names, { annotations: :ranges }],
                       preprocessor: ->(original, kopy) {
                         # See: https://github.com/edgeryders/discourse-annotator/issues/220
                         kopy.annotations_count = 0 if kopy.respond_to?(:annotations_count)
                       },
                       postprocessor: ->(original, kopy) {
                         kopy.name = "#{original.name} (COPY)" if kopy.is_a?(DiscourseAnnotator::CodeName)
                       }
      new.save
    end

    def merge_into(merge_into_code)
      raise ArgumentError.new("Can't merge code with self.") if merge_into_code == self
      t = DiscourseAnnotator::Code.find(merge_into_code.id)
      annotations.each { |a| a.update!(code_id: t.id) }
      # Required as otherwise the counter-cache values are not updated (2020-06-30). See: https://github.com/rails/rails/issues/32098
      DiscourseAnnotator::Code.reset_counters(id, :annotations)
      DiscourseAnnotator::Code.reset_counters(t.id, :annotations)
      # Move all child elements to the new code.
      children.each do |c|
        c.parent = t
        c.save!
      end
      reload # IMPORTANT! Otherwise the annotations that were merged into another code are destroyed as well.
      destroy if annotations.none? && is_childless?
    end

  end
end

# Used for debugging to find child-codes with missing parent tags (which shall never happen).
# with_missing_parent = []
# DiscourseAnnotator::Code.find_each {|t| with_missing_parent << t.id unless !t.parent_id || DiscourseAnnotator::Code.exists?(id: t.parent_id) }

# NOTE: No longer in use. A counter_cache column is now used instead.
# def self.with_annotations_count
#   select('discourse_annotator_codes.*, count(discourse_annotator_annotations.id) AS annotations_count')
#       .joins('LEFT OUTER JOIN discourse_annotator_annotations on discourse_annotator_annotations.code_id = discourse_annotator_codes.id')
#       .group('discourse_annotator_codes.id')
# end


