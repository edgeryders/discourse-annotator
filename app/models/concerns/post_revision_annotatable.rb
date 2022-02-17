module PostRevisionAnnotatable
  extend ActiveSupport::Concern
  included do

    # NOTE: `after_save` is used instead of `after_create` as for some revisions the revision is first created
    # by discourse and subsequently the `modifications` are set in a separate update transaction.
    after_save :update_annotations

    def update_annotations
      # If annotations are not yet locked to a post-revision and the posts
      # content changed, lock the existing annotations to the created revision.
      if self.post.annotations.any? && self.post.annotations.first.revision_number.blank? && self.modifications.key?(:raw)
        # Update all of the posts annotations as all of them are required to reference the same post-revision.
        self.post.annotations.update_all(revision_number: self.number)
      end
    end

  end
end