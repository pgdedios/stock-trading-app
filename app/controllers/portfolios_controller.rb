class PortfoliosController < ApplicationController
  before_action :authenticate_user!
  def index
    @portfolios = current_user.portfolios.order(updated_at: :desc)
  end

  def show
    @portfolio = current_user.portfolios.find(params[:id])
  end
end
