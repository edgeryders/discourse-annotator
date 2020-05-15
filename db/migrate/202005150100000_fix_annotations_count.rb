class FixAnnotationsCount < ActiveRecord::Migration[5.2]


  def change
    AnnotatorStore.fix_annotations_count
  end


end
