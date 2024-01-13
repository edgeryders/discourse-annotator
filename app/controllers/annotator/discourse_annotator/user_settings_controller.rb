require_dependency 'annotator/application_controller'


class Annotator::DiscourseAnnotator::UserSettingsController < Annotator::ApplicationController


  def valid_action?(name, resource = resource_class)
    %w[destroy].exclude?(name.to_s)
  end

  def records_per_page
    params[:per_page] || 300
  end


end