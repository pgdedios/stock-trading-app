class PagesController < ApplicationController
  before_action :authenticate_user!

  def index
    # data = AlphaVantageApi.get_stock_price(params[:symbol])
    # @symbol = data["Meta Data"].dig("2. Symbol")
    # @stock_price = data.dig("Time Series (Daily)").values.first.dig("1. open")
  end

  def unconfirmed
  end

  def pending_approval
  end
end
