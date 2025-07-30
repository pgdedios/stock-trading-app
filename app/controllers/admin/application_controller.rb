class Admin::ApplicationController < ApplicationController
  before_action :authenticate_admin!

  layout "admin"

  rescue_from ActiveRecord::RecordNotFound, with: :render_admin_not_found

  private

  def authenticate_admin!
    unless current_user&.is_admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end

  def render_admin_not_found
    render template: "admin/errors/not_found", status: 404
  end
end
