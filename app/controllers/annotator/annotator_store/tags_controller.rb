require_dependency 'annotator/application_controller'

# https://github.com/thoughtbot/administrate/blob/master/app/controllers/administrate/application_controller.rb
#
class Annotator::AnnotatorStore::TagsController < Annotator::ApplicationController


  def index
    resources = if api_request?
                  scoped_resource
                else
                  # Search or Tree view
                  params[:search].present? ? scoped_resource : scoped_resource.where(ancestry: nil)
                end
    resources = resources.with_localized_tags(language: AnnotatorStore::UserSetting.language_for_user(current_user))
    resources = resources.where(annotator_store_localized_tags: {name: params[:search] }) if params[:search].present?
    resources = resources.where(creator_id: params[:creator_id]) if params[:creator_id].present?
    resources = case params[:order]
                when 'created_at'
                  resources.order('annotator_store_tags.created_at DESC')
                when 'updated_at'
                  resources.order('annotator_store_tags.updated_at DESC')
                else
                  resources.order('LOWER(annotator_store_localized_tags.name) ASC')
                end
    resources = resources.page(params[:page]).per(records_per_page)

    search_term = params[:search].to_s.strip
    page = Administrate::Page::Collection.new(dashboard)

    respond_to do |format|
      format.html {render locals: {resources: resources, search_term: search_term, page: page, show_search_bar: show_search_bar?}}
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


  def show
    respond_to do |format|
      format.html {render locals: {page: Administrate::Page::Show.new(dashboard, requested_resource)}}
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
    if requested_resource.update(resource_params)
      if resource_params.include?(:merge_tag_id)
        redirect_to annotator_annotator_store_tags_path, notice: 'Codes were successfully merged.'
      else
        redirect_to [namespace, requested_resource], notice: 'Code was successfully updated.'
      end
    else
      render :edit, locals: {page: Administrate::Page::Form.new(dashboard, requested_resource)}
    end
  end


  def destroy
    requested_resource.destroy
    flash[:notice] = 'Code was successfully destroyed.'
    redirect_to action: :index
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


  def records_per_page
    params[:per_page] || 50
  end

  private

  def api_request?
    request.format.json? || request.format.xml?
  end

end


#scope = scope.joins(:names).where(annotator_store_tag_names: {name: params[:search] }) if params[:search].present?
#resources = Administrate::Search.new(scope, dashboard_class, search_term).run
#resources = apply_collection_includes(resources)
#resources = params[:search].present? ? order.apply(resources) : resources.order(updated_at: :desc)
