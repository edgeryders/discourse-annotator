json.total @total
json.rows do
  json.array! @annotations, partial: 'annotator/discourse_annotator/annotations/annotation', as: :annotation, current_user: @current_user
end
