require_dependency 'annotator/application_controller'


class Annotator::DiscourseAnnotator::ProjectsController < Annotator::ApplicationController


  def index
    search_term = params[:search].to_s.strip
    resources = Administrate::Search.new(scoped_resource.with_codes_count, dashboard, search_term).run
    resources = apply_collection_includes(resources)
    resources = if params.dig(:discourse_annotator__project, :order) == 'codes_count'
                  resources.order("codes_count #{params[:discourse_annotator__project][:direction]}")
                else
                  order.apply(resources)
                end
    resources = resources.page(params[:page]).per(records_per_page)
    page = Administrate::Page::Collection.new(dashboard, order: order)
    filters = Administrate::Search.new(scoped_resource, dashboard, search_term).valid_filters

    Rails.logger.debug("Resources: #{resources.inspect}")
    respond_to do |format|
      format.html {
        render locals: {
          resources: resources,
          search_term: search_term,
          page: page,
          show_search_bar: show_search_bar?,
          filters: filters,
        }
      }
      format.json {
        render json: JSON.pretty_generate(JSON.parse(resources.to_json))
      }
    end
  end




  def order
    @order ||= Administrate::Order.new(
      params.fetch(resource_name, {}).fetch(:order, 'name'),
      params.fetch(resource_name, {}).fetch(:direction, 'asc'),
    )
  end

  def existing_action?(resource, action_name)
    %w[destroy].exclude?(action_name.to_s)
  end

  def records_per_page
    params[:per_page] || 300
  end


  private

  def api_request?
    request.format.json? || request.format.xml?
  end

end