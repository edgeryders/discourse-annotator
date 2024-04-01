module DiscourseAnnotator
  class ImageAnnotation < Annotation

    # Validations
    validates :src, presence: true
    validates :shape, presence: true
    validates :units, presence: true
    validates :geometry, presence: true


    def image_annotation?
      true
    end


  end
end
