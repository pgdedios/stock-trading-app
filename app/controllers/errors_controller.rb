class ErrorsController < ApplicationController
  before_action :authenticate_user!

  def not_found
    redirect_to root_path
    flash[:alert] = "Path not found."
  end
end
