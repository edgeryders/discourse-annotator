# https://github.com/thoughtbot/administrate/blob/master/app/controllers/administrate/application_controller.rb

class Annotator::ApplicationController < Administrate::ApplicationController
  include ::CurrentUser
  helper :all

  protect_from_forgery prepend: true

  before_action :ensure_logged_in
  before_action :ensure_staff_or_annotator_group_member
  before_action :set_headers

  unless Rails.application.config.consider_all_requests_local
    # NOTE: The order is important.
    # http://stackoverflow.com/questions/9119066/how-do-i-determine-which-exception-handler-rescue-from-will-choose-in-rails
    # rescue_from Exception, with: :render_500
    rescue_from ActionController::UnknownFormat, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from AbstractController::ActionNotFound, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  def front
  end

  def namespace
    :annotator_discourse_annotator
  end

  # See: https://github.com/thoughtbot/administrate/issues/442
  def order
    @order ||= Administrate::Order.new(
      params.fetch(resource_name, {}).fetch(:order, 'created_at'),
      params.fetch(resource_name, {}).fetch(:direction, 'desc'),
    )
  end

  # Page not found
  # https://stackoverflow.com/questions/2385799/how-to-redirect-to-a-404-in-rails
  def render_404
    respond_to do |format|
      format.html { render template: 'annotator/errors/not_found', status: 404 }
      format.json { render template: 'annotator/errors/not_found', status: 404 }
      format.xml { head :not_found }
      format.any { head :not_found }
    end
  end

  def paginate_resources(resources)
    resources.page(params[:page]).per(records_per_page)
  end

  private

  def set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Expose-Headers'] = 'ETag'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PATCH, PUT, DELETE, OPTIONS, HEAD'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,If-Modified-Since,If-None-Match'
    headers['Access-Control-Max-Age'] = '86400'
  end

  def ensure_logged_in
    raise Discourse::NotLoggedIn.new unless current_user.present?
  end

  def ensure_staff
    raise Discourse::InvalidAccess.new unless current_user && current_user.staff?
  end

  def ensure_admin
    raise Discourse::InvalidAccess.new unless current_user && current_user.admin?
  end

  def ensure_staff_or_annotator_group_member
    raise Discourse::InvalidAccess.new unless current_user && (current_user.staff? || current_user.groups.pluck(:name).map(&:downcase).include?('annotator'))
  end

end
