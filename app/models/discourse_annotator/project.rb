require 'deep_cloneable'

module DiscourseAnnotator
  class Project < ActiveRecord::Base

    has_many :codes, dependent: :destroy

    validates :name, presence: true, uniqueness: true

    scope :with_codes_count, -> {
      select('discourse_annotator_projects.*, count(discourse_annotator_codes.id) AS codes_count').left_joins(:codes).group('discourse_annotator_projects.id')
    }

    def annotations
      DiscourseAnnotator::Annotation.where("discourse_annotator_annotations.code_id IN(#{codes.select(:id).to_sql})")
    end

    def posts
      Post.where("posts.id IN(#{annotations.select(:post_id).to_sql})")
    end

    # Performance optimized delete of a project and all it's dependencies.
    def fast_delete
      DiscourseAnnotator::CodeName.where(code_id: code_ids).delete_all
      DiscourseAnnotator::LocalizedCode.where(code_id: code_ids).delete_all
      DiscourseAnnotator::Range.where(annotation_id: DiscourseAnnotator::Annotation.where(code_id: code_ids).select(:id)).delete_all
      DiscourseAnnotator::Annotation.where(code_id: code_ids).delete_all
      delete
    end

  end
end
