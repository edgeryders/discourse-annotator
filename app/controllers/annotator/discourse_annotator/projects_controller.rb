require_dependency 'annotator/application_controller'


class Annotator::DiscourseAnnotator::ProjectsController < Annotator::ApplicationController


  def index
    search_term = params[:search].to_s.strip
    resources = Administrate::Search.new(scoped_resource.with_codes_count, dashboard_class, search_term).run
    resources = apply_collection_includes(resources)
    resources = if params.dig(:discourse_annotator__project, :order) == 'codes_count'
                  resources.order("codes_count #{params[:discourse_annotator__project][:direction]}")
                else
                  order.apply(resources)
                end
    resources = resources.page(params[:page]).per(records_per_page)
    page = Administrate::Page::Collection.new(dashboard, order: order)
    respond_to do |format|
      format.html {
        render locals: {
          resources: resources,
          search_term: search_term,
          page: page,
          show_search_bar: show_search_bar?,
        }
      }
      format.json {
        render json: JSON.pretty_generate(JSON.parse(resources.to_json))
      }
    end
  end

  def valid_action?(name, resource = resource_class)
    %w[destroy].exclude?(name.to_s)
  end

  def records_per_page
    params[:per_page] || 300
  end


  private

  def api_request?
    request.format.json? || request.format.xml?
  end

end