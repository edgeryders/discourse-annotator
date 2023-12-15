require 'activejob-status'


class Annotator::DiscourseAnnotator::JobsController < Annotator::ApplicationController

  def show
    @project = DiscourseAnnotator::Project.find(params[:project_id])
  end

  def status
    render json: ActiveJob::Status.get(params[:id]).to_json, status: :ok
  end

end