require_dependency 'annotator/application_controller'

class Annotator::DiscourseAnnotator::TopicsController < Annotator::ApplicationController

  before_action :set_project, only: [:index, :show]

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

  def show_search_bar?
    true
  end

  # Override this if you have certain roles that require a subset
  # this will be used to set the records shown on the `index` action.
  def scoped_resource
    user_counts = topics_with_annotations_count(@project.annotations.select('id').where(discourse_annotator_annotations: { creator_id: current_user.id }))
    total_counts = topics_with_annotations_count(@project.annotations.select('id'))

    resources = Topic.select("topics.*, COALESCE(tu.annotations_count,0) AS user_annotations_count, COALESCE(tc.annotations_count,0) AS annotations_count")
                     .joins("LEFT OUTER JOIN (#{user_counts.to_sql}) tu ON topics.id = tu.id")
                     .joins("LEFT OUTER JOIN (#{total_counts.to_sql}) tc ON topics.id = tc.id")

    resources = resources.listable_topics # Exclude private messages.

    if params[:annotator_id].present?
      resources = resources.where(id: @project.posts.with_annotations.select(:topic_id).where(discourse_annotator_annotations: { creator_id: params[:annotator_id] }))
    end

    if params[:with_annotations].present?
      resources = resources.where('tc.annotations_count > 0')
    end

    resources = if params.dig(:discourse_annotator__topic, :order).blank?
                  resources.order("annotations_count DESC")
                elsif params.dig(:discourse_annotator__topic, :order) == 'user_annotations_count'
                  resources.order("user_annotations_count #{params[:discourse_annotator__topic][:direction]}")
                elsif params.dig(:discourse_annotator__topic, :order) == 'annotations_count'
                  resources.order("annotations_count #{params[:discourse_annotator__topic][:direction]}")
                else
                  order.apply(resources)
                end
    resources
  end

  def records_per_page
    params[:per_page] || 50
  end

  def resource_class
    ::Topic
  end

  private

  def set_project
    @project = DiscourseAnnotator::Project.find(params[:project_id])
  end

  def topics_with_annotations_count(annotations)
    DiscourseAnnotator::Annotation.select('topic_id AS id, count(id) AS annotations_count').where(id: annotations).group('topic_id')
  end

end




# posts:
# def topics_with_annotations_count(args = {})
#   Topic.select("topics.id, SUM(COALESCE(posts_with_counts.annotations_count,0))::bigint AS annotations_count")
#       .joins("LEFT OUTER JOIN (#{args[:posts].to_sql}) posts_with_counts ON topics.id = posts_with_counts.topic_id")
#       .group('topics.id')
# end


# def namespace
#   :annotator
# end

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

# .joins("LEFT OUTER JOIN discourse_annotator_annotations ON discourse_annotator_annotations.post_id = posts_with_counts.id")
# scope = Topic.select("topics.*, count(posts_with_counts.id) AS annotations_count")
#             .joins("LEFT OUTER JOIN (#{Post.with_annotations_count.to_sql}) posts_with_counts ON topics.id = posts_with_counts.topic_id")
#             .joins("LEFT OUTER JOIN discourse_annotator_annotations ON discourse_annotator_annotations.post_id = posts_with_counts.id")
#             .group('topics.id')
#             .order("annotations_count DESC")
# scope = scope.where(discourse_annotator_annotations: {creator_id: 3})
# scope.to_sql
