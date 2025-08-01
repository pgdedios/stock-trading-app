class PortfoliosController < ApplicationController
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    @q = current_user.portfolios.ransack(params[:q])
    @portfolios = @q.result(distinct: true).order(updated_at: :desc)
  end

  def show
    @portfolio = current_user.portfolios.find(params[:id])
    @transactions = Transaction.for_stock(@portfolio.stock_symbol) # All transactions related to this stock
  end

  private

  def record_not_found
    redirect_to portfolios_path, alert: "Record does not exist."
  end
end
