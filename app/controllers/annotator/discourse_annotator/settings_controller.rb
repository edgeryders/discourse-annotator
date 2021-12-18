require_dependency 'annotator/application_controller'

class Annotator::DiscourseAnnotator::SettingsController < Annotator::ApplicationController


  private

  def requested_resource
    @requested_resource ||= DiscourseAnnotator::Setting.instance
  end


end
