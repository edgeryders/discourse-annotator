require_dependency 'annotator/application_controller'

class Annotator::DiscourseAnnotator::PagesController < Annotator::ApplicationController
  before_action :format_input, only: [:search]

  def index
  end

  def search
    @annotations = DiscourseAnnotator::Project.find(params[:project_id]).annotations.where(search_params)
    @total = @annotations.size
    @current_user = current_user
  end


  private

  def format_input
    params[:search] = {}
    params[:search][:uri] = params[:uri]
  end

  def search_params
    params.require(:search).permit(:uri)
  end

end
