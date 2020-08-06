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