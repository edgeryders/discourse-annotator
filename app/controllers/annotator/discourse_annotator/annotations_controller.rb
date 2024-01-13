require_dependency 'annotator/application_controller'

class Annotator::DiscourseAnnotator::AnnotationsController < Annotator::ApplicationController

  before_action :set_project, only: [:index, :show, :create, :edit, :update]
  before_action :set_annotation, only: [:show, :update, :destroy]
  before_action :set_current_user, only: [:create, :show, :update, :destroy]

  def index
    scope = scoped_resource

    if params[:project_id].present?
      scope = scope.where(code_id: DiscourseAnnotator::Code.where(project_id: params[:project_id]).select(:id))
    end
    scope = scope.where(post_id: ::Topic.find(params[:topic_id]).try(:post_ids)) if params[:topic_id].present?
    scope = scope.where(post_id: params[:post_id]) if params[:post_id].present?
    scope = scope.where(creator_id: params[:creator_id]) if params[:creator_id].present?

    # Only annotations that are tagged with the given Open Ethnographer code(s).
    if params[:code_id].present?
      code_ids = params[:include_sub_codes].present? ? DiscourseAnnotator::Code.find(params[:code_id]).subtree_ids : params[:code_id]
      scope = scope.where(code_id: code_ids)
    end

    search_term = params[:search].to_s.strip
    resources = Administrate::Search.new(scope, dashboard, search_term).run
    resources = apply_collection_includes(resources)
    resources = if params.dig(:discourse_annotator__annotation, :order)
                  if params.dig(:discourse_annotator__annotation, :order) == 'topic_id_and_post_id'
                    direction = params[:discourse_annotator__annotation][:direction]
                    resources.order(topic_id: direction, post_id: direction)
                  else
                    order.apply(resources)
                  end
                else
                  resources.order(created_at: :desc)
                end
    resources = paginate_resources(resources)
    page = Administrate::Page::Collection.new(dashboard, order: order)

    respond_to do |format|
      format.html {
        render locals: {
          resources: resources,
          search_term: search_term,
          page: page,
          show_search_bar: show_search_bar?
        }
      }
      format.json {
        # See: https://github.com/edgeryders/discourse-annotator/issues/201
        resources = resources.left_joins(:post).select('discourse_annotator_annotations.*, posts.user_id as post_creator_id')

        render json: JSON.pretty_generate(JSON.parse(resources.to_json))
      }
    end
  end

  def records_per_page
    params[:per_page] || 50
  end

  # POST /annotations
  def create
    success = true
    # Create one annotation for each provided code-name.
    params[:codes].each do |path|
      code = get_code(path, @project)
      format_client_input_to_rails_convention_for_create(code)

      # Determine the class based on the attributes that are set.
      @annotation = if params[:target].present?
                      DiscourseAnnotator::VideoAnnotation.new(annotation_params)
                    elsif params[:annotation][:geometry].present?
                      DiscourseAnnotator::ImageAnnotation.new(annotation_params)
                    else
                      DiscourseAnnotator::TextAnnotation.new(annotation_params)
                    end
      @annotation.creator = current_user
      success = false unless success && @annotation.save
    end
    respond_to do |format|
      if success
        format.json {
          render :show, status: :created, location: annotator_discourse_annotator_annotations_url(@annotation)
        }
      else
        format.json { render json: @annotation.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /annotations/1
  def show
    respond_to do |format|
      format.html { render locals: { page: Administrate::Page::Show.new(dashboard, requested_resource) } }
      format.json { render :show }
    end
  end

  # PATCH/PUT /annotations/1
  def update
    respond_to do |format|
      format.json {
        format_client_input_to_rails_convention_for_update(@project)
        if @annotation.update(annotation_params)
          render :show, status: :ok, location: annotator_discourse_annotator_annotations_url(@annotation)
        else
          render json: @annotation.errors, status: :unprocessable_entity
        end
      }
      format.html {
        if @annotation.update(annotation_params)
          redirect_to([namespace, @project, @annotation], notice: translate_with_resource("update.success"))
        else
          render :edit, locals: { page: Administrate::Page::Form.new(dashboard, requested_resource) }
        end
      }
    end
  end

  def update_code
    fallback_path = annotator_discourse_annotator_annotations_path
    ids = params[:selected_ids].split(',')
    redirect_back fallback_location: fallback_path, notice: 'No annotations were selected.' and return if ids.blank?
    status = []
    ids.each { |id| status << DiscourseAnnotator::Annotation.find(id).update(code_id: params[:code_id]) }
    msg = []
    msg << "#{status.count(true)} annotations were successfully moved." if status.count(true) > 0
    msg << "#{status.count(false)} annotations could not be moved." if status.count(false) > 0
    redirect_back fallback_location: fallback_path, notice: msg.join(' ')
  end

  def bulk_destroy
    fallback_path = annotator_discourse_annotator_annotations_path
    ids = params[:selected_ids].split(',')
    redirect_back fallback_location: fallback_path, notice: 'No annotations were selected.' and return if ids.blank?
    status = []
    ids.each { |id| status << !!DiscourseAnnotator::Annotation.find(id).destroy }
    msg = []
    msg << "#{status.count(true)} annotations were destroyed." if status.count(true) > 0
    msg << "#{status.count(false)} annotations could not be destroyed." if status.count(false) > 0
    redirect_back fallback_location: fallback_path, notice: msg.join(' ')
  end

  # DELETE /annotations/1
  def destroy
    @annotation.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: annotator_root_path }
      format.json { head :no_content, status: :no_content }
    end
  end

  # OPTIONS /annotations
  def options
    respond_to do |format|
      format.json { render :options }
    end
  end

  # Quick fix: Make the current user available in the json builder partial.
  def set_current_user
    @current_user = current_user
  end

  private

  # Convert the data sent by AnnotatorJS to the format that Rails expects so
  # that we are able to create a proper params object
  # VIDEO annotation input example:
  # {
  #   "uri"=>"/post/",
  #   "target"=>{
  #     "container"=>"vid1",
  #     "src"=>"http://vjs.zencdn.net/v/oceans.mp4",
  #     "ext"=>".mp4"
  #    },
  #   "rangeTime"=>{
  #     "start"=>11.560403,
  #     "end"=>16.2217363
  #   },
  #   "codes"=>["test", "tag", "→", "testtag", "deutsch"],
  #   "updated"=>"2019-06-19T19:39:59.349Z",
  #   "created"=>"2019-06-19T19:39:59.349Z",
  #   "text"=>"",
  #   "media"=>"video",
  #   "ranges"=>[],
  #   "quote"=>"",
  #   "annotator_schema_version"=>"v1.0",
  #   "video_annotation"=>{"uri"=>"/post/1"}
  # }
  #
  # IMAGE annotation input example:
  # {
  #   "url": "http://lloydbleekcollection.cs.uct.ac.za/images/stow/STOW_001.JPG",
  #   "text": "",
  #   "ranges": [],
  #   "quote": "",
  #   "closure_uid_k7l337": 6,
  #   "l": [
  #     {
  #       "type": "rect",
  #       "a": {
  #         "x": 314,
  #         "width": 261,
  #         "y": 207,
  #         "height": 188
  #       }
  #     }
  #   ]
  # }
  def format_client_input_to_rails_convention_for_create(code)
    params[:annotation] = {}
    params[:annotation][:code_id] = code.id

    # VideoAnnotation
    params[:annotation][:uri] = params[:uri] unless params[:uri].blank?
    params[:annotation][:container] = params[:target][:container] unless params[:target].blank?
    params[:annotation][:src] = params[:target][:src] unless params[:target].blank?
    params[:annotation][:ext] = params[:target][:ext] unless params[:target].blank?
    params[:annotation][:start] = params[:rangeTime][:start] unless params[:rangeTime].blank?
    params[:annotation][:end] = params[:rangeTime][:end] unless params[:rangeTime].blank?

    # ImageAnnotation
    # params[:annotation][:page_url] = params[:page_url] unless params[:page_url].blank?
    params[:annotation][:src] = params[:url] unless params[:url].blank?
    params[:annotation][:units] = 'pixel'
    params[:annotation][:shape] = params[:l][0][:type] unless params[:l].blank?
    params[:annotation][:geometry] = params[:l][0][:a].to_json.to_s unless params[:l].blank?

    # TextAnnotation
    params[:annotation][:version] = params[:annotator_schema_version] unless params[:annotator_schema_version].blank?
    params[:annotation][:text] = params[:text] # unless params[:text].blank?
    params[:annotation][:quote] = params[:quote] unless params[:quote].blank?
    params[:annotation][:uri] = params[:uri] unless params[:uri].blank?
    unless params[:uri].blank?
      path, id = params[:uri].split('/').reject(&:empty?)
      if path == 'topic'
        params[:annotation][:topic_id] = id
      elsif path == 'post'
        params[:annotation][:post_id] = id
      end
    end
    params[:annotation][:ranges_attributes] = params[:ranges].map do |r|
      range = {}
      range[:start] = r[:start]
      range[:end] = r[:end]
      range[:start_offset] = r[:startOffset]
      range[:end_offset] = r[:endOffset]
      range
    end unless params[:ranges].blank?
  end

  # Convert the data sent by AnnotatorJS to the format that Rails expects so
  # that we are able to create a proper params object
  def format_client_input_to_rails_convention_for_update(project)
    code = get_code(params[:codes].first, project)
    format_client_input_to_rails_convention_for_create(code)
    # Annotator sends duplicate ranges when an annotation is updated which would then be saved.
    # As ranges are not allowed to be changed we can simply remove the provided attributes.
    params[:annotation][:ranges_attributes] = {}
  end

  # Only allow a trusted parameter 'white list' through.
  def annotation_params
    params.require(:annotation).permit(
      :code_id, :uri, :post_id, :topic_id,
      # VideoAnnotation
      :container, :src, :ext, :start, :end,
      # Image Annotation
      :src, :shape, :units, :geometry,
      # TextAnnotation
      :text, :quote, :version, ranges_attributes: [:start, :end, :start_offset, :end_offset]
    )
  end

  # codes in the path can be separated by ` -> ` or ` → `
  def get_code(path, project)
    return if path.blank?
    normalized_path = path.gsub('->', DiscourseAnnotator::LocalizedCode.path_separator)
    language = DiscourseAnnotator::UserSetting.language_for_user(current_user)
    path_items = []
    code = nil
    normalized_path.split(DiscourseAnnotator::LocalizedCode.path_separator).map(&:strip).each do |code_name|
      path_items << code_name
      code = DiscourseAnnotator::Code.
        where(project_id: project.id).
        joins(:localized_codes).
        where("lower(discourse_annotator_localized_codes.path) = ?", path_items.join(DiscourseAnnotator::LocalizedCode.path_separator).downcase)&.first ||
        create_code!(parent: code, name: code_name, language: language, project: project)
    end
    code
  end

  def set_annotation
    @annotation = DiscourseAnnotator::Annotation.find(params[:id])
  end

  def set_project
    @project = DiscourseAnnotator::Project.find(params[:project_id])
  end

  def valid_action?(name, resource = resource_class)
    %w[show].exclude?(name.to_s)
  end

  # name:
  # language:
  # parent:
  # project:
  def create_code!(args = {})
    code = DiscourseAnnotator::Code.new(parent: args[:parent], creator: current_user, project: args[:project])
    code.names.build(name: args[:name], language: args[:language])
    code.save!
    code
  end

end

# Only annotations where the posts topics are tagged with the given discourse tag.
# if params[:discourse_tag].present?
#   if (tag = ::Tag.find_by(name: params[:discourse_tag]))
#     scope = scope.where(post_id: Post.where(topic_id: tag.topic_ids).ids)
#   else
#     scope = scope.none
#   end
# end
