
class DiscourseAnnotator::ImageAnnotationDashboard < DiscourseAnnotator::AnnotationDashboard



  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
      :id,
      :type,
      :src,
      :shape,
      :units,
      :geometry,
      :code,
      :creator,
      :created_at,
      :updated_at,
      :topic,
  ].freeze


end