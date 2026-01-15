require_dependency 'annotator/application_controller'


class Annotator::DiscourseAnnotator::UserSettingsController < Annotator::ApplicationController


  def existing_action?(resource, action_name)
    %w[destroy].exclude?(action_name.to_s)
  end

  def records_per_page
    params[:per_page] || 300
  end


end