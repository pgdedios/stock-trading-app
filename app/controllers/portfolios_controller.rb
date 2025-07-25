class PortfoliosController < ApplicationController
  before_action :authenticate_user!
  def index
    @portfolios = Portfolio.where(user_id: current_user.id)
  end

  def show
    @portfolio = current_user.portfolios.find(params[:id])
  end
end
