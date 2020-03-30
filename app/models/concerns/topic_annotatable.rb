module TopicAnnotatable
  extend ActiveSupport::Concern
  included do


    has_many :annotations, through: :posts



    scope :with_annotations, -> {includes(posts: :annotations).where.not(annotator_store_annotations: {id: nil})}


    def self.with_annotations_count
      select("topics.*, count(posts.id) AS annotations_count")
          .joins("LEFT OUTER JOIN (#{Post.with_annotations_count.to_sql}) posts ON topics.id = posts.topic_id")
          .group('topics.id')
          .order("annotations_count DESC")
    end


  end
end
