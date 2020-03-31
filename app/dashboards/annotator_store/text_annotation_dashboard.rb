
class AnnotatorStore::TextAnnotationDashboard < AnnotatorStore::AnnotationDashboard


  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
      :id,
      :type,
      :quote,
      :text,
      :tag,
      :creator,
      :created_at,
      :updated_at,
      :topic,
  ].freeze


end
