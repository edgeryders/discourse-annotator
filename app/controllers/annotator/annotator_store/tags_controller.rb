require_dependency 'annotator/application_controller'

# https://github.com/thoughtbot/administrate/blob/master/app/controllers/administrate/application_controller.rb
#
class Annotator::AnnotatorStore::TagsController < Annotator::ApplicationController


  skip_before_action :ensure_logged_in, :ensure_staff_or_annotator_group_member,
                     if: proc { |c| api_request? && c.action_name == "index" && AnnotatorStore::Setting.instance.public_codes_list_api_endpoint? }


  def index
    language = (current_user.present? && api_request?) ? AnnotatorStore::UserSetting.language_for_user(current_user) : AnnotatorStore::Language.english
    resources = if api_request?
                  scoped_resource
                else
                  # Search or Tree view
                  params[:search].present? ? scoped_resource : scoped_resource.where(ancestry: nil)
                end
    resources = resources.with_localized_tags(language: language)
    # resources = resources.where("' ' || annotator_store_localized_tags.path ILIKE ?", "% #{params[:search].split.join('%')}%") if params[:search].present?
    resources = resources.where("annotator_store_localized_tags.path ILIKE ?", "%#{params[:search].split.join('%')}%") if params[:search].present?
    resources = resources.where(creator_id: params[:creator_id]) if params[:creator_id].present?
    resources = case params[:order]
                when 'created_at'
                  resources.order('annotator_store_tags.created_at DESC')
                when 'updated_at'
                  resources.order('annotator_store_tags.updated_at DESC')
                else
                  resources.order('LOWER(annotator_store_localized_tags.name) ASC')
                end
    if params[:discourse_tag].present? && (tag = ::Tag.find_by(name: params[:discourse_tag]))
      resources = resources.where(id: AnnotatorStore::Annotation.where(topic_id: tag.topic_ids).select(:tag_id))
    end
    resources = resources.page(params[:page]).per(records_per_page)

    search_term = params[:search].to_s.strip
    page = Administrate::Page::Collection.new(dashboard)

    respond_to do |format|
      format.html {
        render locals: {resources: resources, search_term: search_term, page: page, show_search_bar: show_search_bar?}
      }
      format.json {
        render json: JSON.pretty_generate(
            JSON.parse(
                resources.to_json(
                    except: [:name_legacy], include: {names: {only: [:name], methods: [:locale]}}
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
      format.html { render locals: {page: Administrate::Page::Show.new(dashboard, requested_resource)} }
      format.json {
        render json: JSON.pretty_generate(
            JSON.parse(
                requested_resource.to_json(
                    except: [:name_legacy], include: {names: {only: [:name], methods: [:locale]}}
                )
            )
        )
      }
    end
  end


  def create
    resource = resource_class.new(resource_params)
    resource.creator = current_user

    if resource.save
      redirect_to [namespace, resource], notice: 'Code was successfully created.'
    else
      render :new, locals: {page: Administrate::Page::Form.new(dashboard, resource)}
    end
  end


  def update
    respond_to do |format|
      if requested_resource.update(resource_params)
        format.html {
          redirect_to [namespace, requested_resource], notice: 'Code was successfully updated.'
        }
        format.js {}
      else
        format.html {
          render :edit, locals: {page: Administrate::Page::Form.new(dashboard, requested_resource)}
        }
        format.js {}
      end
    end
  end


  def copy
    msg = requested_resource.copy ? 'Code was successfully copied.' : 'An error occurred while coping the code!'
    redirect_back fallback_location: annotator_annotator_store_tags_path(creator_id: current_user.id), notice: msg
  end


  def merge
    render locals: {
        page: Administrate::Page::Form.new(dashboard, requested_resource),
    }
  end


  def merge_into
    if requested_resource.merge_into(AnnotatorStore::Tag.find(params[:tag][:merge_into_tag_id]))
      redirect_to annotator_annotator_store_tags_path(creator_id: current_user.id), notice: 'Codes were successfully merged.'
    else
      render :merge, locals: {page: Administrate::Page::Form.new(dashboard, requested_resource)}
    end
  end


  def destroy
    requested_resource.destroy
    flash[:notice] = 'Code was successfully destroyed.'
    redirect_to action: :index
  end


  def records_per_page
    params[:per_page] || 300
  end


  private

  def api_request?
    request.format.json? || request.format.xml?
  end

end


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


# scope = scope.joins(:names).where(annotator_store_tag_names: {name: params[:search] }) if params[:search].present?
# resources = Administrate::Search.new(scope, dashboard_class, search_term).run
# resources = apply_collection_includes(resources)
# resources = params[:search].present? ? order.apply(resources) : resources.order(updated_at: :desc)
