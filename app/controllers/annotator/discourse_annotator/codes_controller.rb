require_dependency 'annotator/application_controller'
require 'activejob-status'

# https://github.com/thoughtbot/administrate/blob/master/app/controllers/administrate/application_controller.rb
#
class Annotator::DiscourseAnnotator::CodesController < Annotator::ApplicationController
  include ActionView::Helpers::UrlHelper

  include Annotator::ApplicationHelper

  before_action :set_project

  skip_before_action :ensure_logged_in, :ensure_staff_or_annotator_group_member,
                     if: proc { |c| api_request? &&
                       c.action_name == "index" &&
                       DiscourseAnnotator::Setting.instance.public_codes_list_api_endpoint?
                     }

  def index
    resources = scoped_resource
    # 1. Apply filter
    resources = resources.where(project_id: params[:project_id]) if params[:project_id].present?
    resources = resources.where(creator_id: params[:creator_id]) if params[:creator_id].present?
    if params[:search].present?
      resources = resources.where("discourse_annotator_localized_codes.path ILIKE ?", "%#{params[:search].split.join('%')}%")
    end
    # 2. For the tree-view get and limit the results to the root codes of matching codes.
    # Note: Must be done before pagination is applied.
    if !params[:search].present? && params[:view] != 'table' && request.format.html?
      # See: https://github.com/edgeryders/discourse-annotator/issues/217
      root_ids = resources.select('id, ancestry').map { |r| r.ancestry ? r.ancestry.split('/')[0] : r.id }.uniq
      resources = scoped_resource.where(id: root_ids)
    end
    # 3. Sorting
    resources = order_codes(codes: resources, order: params[:order])
    # 4. Select & Joins
    if params[:search].present?
      # See: https://github.com/edgeryders/discourse-annotator/issues/200#issuecomment-728110668
      resources = resources.with_localized_path
    else
      language = (current_user.present? && api_request?) ?
                   DiscourseAnnotator::UserSetting.language_for_user(current_user) :
                   DiscourseAnnotator::Language.english
      resources = resources.with_localized_codes(language: language)
    end
    # 5. Pagination
    resources = resources.page(params[:page]).per(records_per_page)

    search_term = params[:search].to_s.strip
    page = Administrate::Page::Collection.new(dashboard)

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
        render json: JSON.pretty_generate(
          JSON.parse(
            resources.to_json(
              only: [:id, :description, :creator_id, :created_at, :updated_at, :ancestry, :annotations_count],
              include: { names: { only: [:name], methods: [:locale] } }
            )
          )
        )
      }
    end
  end

  def new
    resource = resource_class.new
    resource.creator = current_user
    authorize_resource(resource)
    render locals: {
      page: Administrate::Page::Form.new(dashboard, resource),
    }
  end

  def show
    respond_to do |format|
      format.html { render locals: { page: Administrate::Page::Show.new(dashboard, requested_resource) } }
      format.json {
        render json: JSON.pretty_generate(
          JSON.parse(
            requested_resource.to_json(
              include: { names: { only: [:name], methods: [:locale] } }
            )
          )
        )
      }
    end
  end

  def create
    resource = resource_class.new(resource_params)
    resource.creator = current_user
    resource.project = @project

    if resource.save
      redirect_to(
        annotator_discourse_annotator_project_code_path(project_id: @project.id, id: resource.id),
        notice: 'Code was successfully created.'
      )
    else
      render :new, locals: { page: Administrate::Page::Form.new(dashboard, resource) }
    end
  end

  def update
    respond_to do |format|
      if requested_resource.update(resource_params)
        format.html {
          redirect_to(
            annotator_discourse_annotator_project_code_path(project_id: @project.id, id: requested_resource.id),
            notice: 'Code was successfully updated.')
        }
        format.js {}
      else
        format.html {
          render :edit, locals: { page: Administrate::Page::Form.new(dashboard, requested_resource) }
        }
        format.js {}
      end
    end
  end

  def update_parent
    ids = params[:selected_ids].split(',')
    redirect_back fallback_location: fallback_path, notice: 'No codes were selected.' and return if ids.blank?
    status = []
    ids.each { |id| status << DiscourseAnnotator::Code.find(id).update(parent_id: params[:parent_id]) }
    msg = []
    msg << "#{status.count(true)} codes were successfully moved." if status.count(true) > 0
    msg << "#{status.count(false)} codes could not be moved." if status.count(false) > 0
    redirect_back fallback_location: fallback_path, notice: msg.join(' ')
  end

  def move_to_project
    ids = params[:selected_ids].split(',')
    redirect_back fallback_location: fallback_path, notice: 'No codes were selected.' and return if ids.blank?
    redirect_back fallback_location: fallback_path, notice: 'No project was selected.' and return if params[:target_project_id].blank?
    codes = DiscourseAnnotator::Code.top_level_codes(ids)
    project = DiscourseAnnotator::Project.find(params[:target_project_id])
    codes.each { |code| code.move_to_project!(project) }
    redirect_back fallback_location: fallback_path, notice: "Moved codes into project \"#{project.name}\"."
  end

  def copy_to_project
    code_ids = params[:selected_ids].split(',')
    redirect_back fallback_location: fallback_path, notice: 'No codes were selected.' and return if code_ids.blank?
    redirect_back fallback_location: fallback_path, notice: 'No project was selected.' and return if params[:target_project_id].blank?
    project = DiscourseAnnotator::Project.find(params[:target_project_id])
    include_descendants = ActiveModel::Type::Boolean.new.cast(params[:include_descendants])
    job = DiscourseAnnotator::CopyCodesJob.perform_later(
      code_ids: code_ids,
      project_id: project.id,
      include_descendants: include_descendants
    )
    link = link_to(
      'here',
      annotator_discourse_annotator_project_job_path(project, job.job_id),
      target: '_blank',
    )
    redirect_back fallback_location: fallback_path,
                  notice: "Copying codes into project \"#{project.name}\". Monitor the progress #{link}."
  end

  def copy
    render locals: {
      page: Administrate::Page::Form.new(dashboard, requested_resource)
    }
  end

  def create_copy
    copy = requested_resource.create_copy(project_id: params[:code][:project_id])
    if copy
      msg = "Code was successfully copied."
      msg += ' ' + (helpers.link_to 'Show copy', annotator_discourse_annotator_project_code_path(id: copy.id, project_id: params[:code][:project_id]))
    else
      msg = 'An error occurred while copying the code!'
    end
    redirect_back fallback_location: fallback_path, notice: msg
  end

  def merge
    render locals: {
      page: Administrate::Page::Form.new(dashboard, requested_resource)
    }
  end

  def merge_into
    if requested_resource.merge_into(DiscourseAnnotator::Code.find(params[:code][:merge_into_code_id]))
      redirect_to fallback_path, notice: 'Codes were successfully merged.'
    else
      render :merge, locals: { page: Administrate::Page::Form.new(dashboard, requested_resource) }
    end
  end

  def tree_item
    @code = requested_resource
    @show_children = params[:show_children] == 'true'
    respond_to :js
  end

  def destroy
    requested_resource.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = 'Code was successfully destroyed.'
        redirect_to fallback_path
      }
      format.js
    end
  end

  def records_per_page
    params[:per_page] || 300
  end

  private

  def fallback_path
    annotator_discourse_annotator_project_codes_path(project_id: @project.id)
  end

  def api_request?
    request.format.json? || request.format.xml?
  end

  def set_project
    @project = DiscourseAnnotator::Project.find(params[:project_id])
  end

end

# if params[:discourse_tag].present? && (discourse_tag = ::Tag.find_by(name: params[:discourse_tag]))
#   resources = resources.where(id: DiscourseAnnotator::Annotation.where(topic_id: discourse_tag.topic_ids).select(:code_id))
# end

# Overwrite any of the RESTful controller actions to implement custom behavior
# For example, you may want to send an email after a foo is updated.
#
# def update
#   foo = Foo.find(params[:id])
#   foo.update(params[:foo])
#   send_foo_updated_email
# end

# Override this method to specify custom lookup behavior.
# This will be used to set the resource for the `show`, `edit`, and `update`
# actions.
#
# def find_resource(param)
#   Foo.find_by!(slug: param)
# end

# scope = scope.joins(:names).where(discourse_annotator_code_names: {name: params[:search] }) if params[:search].present?
# resources = Administrate::Search.new(scope, dashboard, search_term).run
# resources = apply_collection_includes(resources)
# resources = params[:search].present? ? order.apply(resources) : resources.order(updated_at: :desc)
