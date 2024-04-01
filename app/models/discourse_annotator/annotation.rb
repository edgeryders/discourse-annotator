module DiscourseAnnotator
  class Annotation < ActiveRecord::Base

    # Associations
    belongs_to :code, counter_cache: true
    belongs_to :creator, class_name: '::User'
    belongs_to :post, optional: true
    belongs_to :topic, optional: true
    # Note: Only text-annotations use ranges. The declaration is kept here to simplify copying codes with all associated
    # objects. This requires that all annotations respond to a `ranges` attribute.
    has_many :ranges, foreign_key: 'annotation_id', dependent: :delete_all, autosave: true


    # Validations
    validates :type, presence: true, inclusion: {
      in: %w(DiscourseAnnotator::TextAnnotation DiscourseAnnotator::ImageAnnotation DiscourseAnnotator::VideoAnnotation)
    }
    validates :creator, presence: true
    validates :code, presence: true
    validates_length_of :ranges, maximum: 1


    # Callbacks
    before_validation on: :create do
      # NOTE: All annotations that belong to the same post must reference the same post revision.
      if self.post_id.present? && self.post && self.post.annotations.any?
        self.revision_number = self.post.annotations.first.revision_number
      end

      self.topic = post&.topic if topic_id.blank?
    end

    # --- Instance Methods --- #

    def topic_id_and_post_id
      "#{topic_id}/#{post_id}"
    end

    def text_annotation?
      false
    end

    def video_annotation?
      false
    end

    def image_annotation?
      false
    end

  end
end

# Get all with more than one range (used for debugging).
# DiscourseAnnotator::Annotation.select("discourse_annotator_annotations.*").joins(:ranges).group("discourse_annotator_annotations.id").having("count(discourse_annotator_ranges.id) > ?", 1)