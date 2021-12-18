require_dependency 'annotator/application_controller'

class Annotator::DiscourseAnnotator::UserSettingsController < Annotator::ApplicationController


  def valid_action?(name, resource = resource_class)
    %w[destroy show ].exclude?(name.to_s)
  end


end