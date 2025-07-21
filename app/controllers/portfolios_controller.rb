class PortfoliosController < ApplicationController
  before_action :authenticate_user!
  def index
    @portfolios = Portfolio.where(user_id: current_user.id)
  end

  def new
  end

  def create
  end

  def show
  end

  def update
  end

  def destroy
  end
end
