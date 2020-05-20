require_dependency 'annotator/application_controller'

class Annotator::AnnotatorStore::SettingsController < Annotator::ApplicationController


  private

  def requested_resource
    @requested_resource ||= AnnotatorStore::Setting.instance
  end


end
