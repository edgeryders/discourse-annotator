module DiscourseAnnotator
  class TextAnnotation < Annotation


    # Allow saving of attributes on associated records through the parent,
    # :autosave option is automatically enabled on every association
    accepts_nested_attributes_for :ranges


    # Validations
    validates :version, presence: true
    validates :quote, presence: true
    validates :uri, presence: true
    validates :post, presence: true, unless: proc {|a| a.topic.present?}
    validates :topic, presence: true


    def text_annotation?
      true
    end


  end
end
