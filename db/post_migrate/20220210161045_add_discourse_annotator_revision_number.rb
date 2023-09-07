class AddDiscourseAnnotatorRevisionNumber < ActiveRecord::Migration[6.1]

  def change
    add_column :discourse_annotator_annotations, :revision_number, :integer

    DiscourseAnnotator::Annotation.all.each do |annotation|
      annotation.update_column(:revision_number, annotation.post&.revisions&.last&.number || 1)
    end

    change_column :discourse_annotator_annotations, :revision_number, :integer, null: false
  end

end
