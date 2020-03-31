module AnnotatorStore
  class Annotation < ActiveRecord::Base

    # Associations
    belongs_to :tag, counter_cache: true
    belongs_to :creator, class_name: '::User'
    belongs_to :post
    belongs_to :topic

    # Validations
    validates :type, presence: true, inclusion: {
        in: %w(AnnotatorStore::TextAnnotation AnnotatorStore::ImageAnnotation AnnotatorStore::VideoAnnotation)
    }
    validates :creator, presence: true
    validates :tag, presence: true

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


