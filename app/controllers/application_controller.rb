class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :redirect_admin_to_admin_panel, if: :user_signed_in?

  protected

  # To allow additional parameters in devise.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :is_admin, :is_approve ])
  end

  # Redirect admin users to admin panel after sign in
  def after_sign_in_path_for(resource)
    if resource.is_admin?
      admin_root_path
    else
      root_path
    end
  end

  private

  # Redirect admin users to admin panel automatically
  def redirect_admin_to_admin_panel
    if current_user&.is_admin? && !request.path.start_with?("/admin") && !devise_controller?
      redirect_to admin_root_path
    end
  end
end
