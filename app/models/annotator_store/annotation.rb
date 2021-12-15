module AnnotatorStore
  class Annotation < ActiveRecord::Base

    # Associations
    belongs_to :tag, counter_cache: true
    belongs_to :creator, class_name: '::User'
    belongs_to :post
    belongs_to :topic
    # Note: Only text-annotations use ranges. The declaration is kept here to simplify copying codes with all associated
    # objects. This requires that all annotations respond to a `ranges` attribute.
    has_many :ranges, foreign_key: 'annotation_id', dependent: :destroy, autosave: true

    # Validations
    validates :type, presence: true, inclusion: {
        in: %w(AnnotatorStore::TextAnnotation AnnotatorStore::ImageAnnotation AnnotatorStore::VideoAnnotation)
    }
    validates :creator, presence: true
    validates :tag, presence: true

    validates_length_of :ranges, maximum: 1


    # Callbacks
    before_validation on: :create do
      self.topic = post&.topic if topic.blank?
    end


    # --- Instance Methods --- #

    # Alias. Used by administrate.
    # Required due to https://github.com/thoughtbot/administrate/issues/1681
    # An upgrade of administrate is not easily possible right now due to dependencies.
    def code
      tag
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
# AnnotatorStore::Annotation.select("annotator_store_annotations.*").joins(:ranges).group("annotator_store_annotations.id").having("count(annotator_store_ranges.id) > ?", 1)