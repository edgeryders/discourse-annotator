Dummy::Application.routes.draw do
  mount DiscourseAnnotator::Engine => '/discourse_annotator'
end
