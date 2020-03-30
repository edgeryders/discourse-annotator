require_dependency 'annotator/application_controller'

class Annotator::TopicsController < Annotator::ApplicationController


  # def index
  #   search_term = params[:search].to_s.strip
  #   resources = Administrate::Search.new(scoped_resource, dashboard_class, search_term).run
  #   resources = apply_collection_includes(resources)
  #   resources = order.apply(resources)
  #   resources = resources.page(params[:page]).per(records_per_page)
  #   page = Administrate::Page::Collection.new(dashboard, order: order)
  #
  #   render locals: {
  #     resources: resources,
  #     search_term: search_term,
  #     page: page,
  #     show_search_bar: show_search_bar?,
  #   }
  # end


  def show
    opts = params.slice(:username_filters, :filter, :page, :post_number, :show_deleted)
    page = params[:page]&.to_i

    @current_user = current_user
    @topic_view = TopicView.new(params[:id] || params[:topic_id], current_user, opts)

    if page.present? && ((page < 0) || ((page - 1) * @topic_view.chunk_size > @topic_view.topic.highest_post_number))
      raise Discourse::NotFound
    end
  end


  # disable 'edit' and 'destroy' links
  def valid_action?(name, resource = resource_class)
    %w[edit destroy].exclude?(name.to_s) && super
  end


  def namespace
    'annotator'
  end


  def show_search_bar?
    true
  end

  # Override this if you have certain roles that require a subset
  # this will be used to set the records shown on the `index` action.
  def scoped_resource
    resources = Topic
    resources = resources.select("topics.*, SUM(posts_with_counts.annotations_count)::bigint AS annotations_count")
                    .joins("LEFT OUTER JOIN (#{Post.with_annotations_count.to_sql}) posts_with_counts ON topics.id = posts_with_counts.topic_id")
                    .group('topics.id')


    if params[:annotator_id].present?
      resources = resources.where(id: Post.select(:topic_id).with_annotations.where(annotator_store_annotations: {creator_id: params[:annotator_id]}) )
    end


    resources = if params.dig(:topic, :order) == 'annotations_count'
                  resources.order("annotations_count #{params[:topic][:direction] || 'DESC'}")
                else
                  order.apply(resources)
                end
    resources
  end

  def records_per_page
    params[:per_page] || 50
  end


end


                    # .joins("LEFT OUTER JOIN annotator_store_annotations ON annotator_store_annotations.post_id = posts_with_counts.id")
# scope = Topic.select("topics.*, count(posts_with_counts.id) AS annotations_count")
#             .joins("LEFT OUTER JOIN (#{Post.with_annotations_count.to_sql}) posts_with_counts ON topics.id = posts_with_counts.topic_id")
#             .joins("LEFT OUTER JOIN annotator_store_annotations ON annotator_store_annotations.post_id = posts_with_counts.id")
#             .group('topics.id')
#             .order("annotations_count DESC")
# scope = scope.where(annotator_store_annotations: {creator_id: 3})
# scope.to_sql
