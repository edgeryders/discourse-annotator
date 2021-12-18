module PostAnnotatable
  extend ActiveSupport::Concern
  included do


    has_many :annotations, dependent: :delete_all, class_name: 'DiscourseAnnotator::Annotation'

    scope :with_annotations, -> {joins(:annotations)}
    scope :without_annotations, -> {left_outer_joins(:annotations).where(annotations: {id: nil})}
    scope :with_annotations_count, -> {
      select('posts.*, count(discourse_annotator_annotations.id) AS annotations_count').left_joins(:annotations).group('posts.id')
    }


  end
end
