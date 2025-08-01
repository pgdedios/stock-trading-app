class TransactionsController < ApplicationController
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    @q = current_user.transactions.ransack(params[:q])
    @transactions = @q.result(distinct: true).order(created_at: :desc)
  end

  def new
    @transaction = Transaction.new
    @type = params[:type] || "buy"

    if @type == "sell"
      @companies = current_user.portfolios.map(&:attributes)
    else
      @companies = JSON.parse(File.read(Rails.root.join("lib/assets/data/companies.json")))
    end
  end



  def create
    @transaction = current_user.transactions.build(transaction_params)

    if @transaction.save
      redirect_to transactions_path, notice: "Transaction completed!"
    else
      flash[:alert] = "Transaction failed."
      if transaction_params[:transaction_type] == "buy"
        @companies = JSON.parse(File.read(Rails.root.join("lib/assets/data/companies.json")))
        render :new, status: :unprocessable_entity
      else
        @companies = current_user.portfolios.map(&:attributes)
        render :new, status: :unprocessable_entity
      end
    end
  end

  def show
    @transaction = current_user.transactions.find(params[:id])
  end

  def fetch_price
    data = AlphaVantageApi.get_stock_price(params[:stock_symbol])
    price = data.dig("Time Series (Daily)")&.values&.first&.dig("1. open")

    if price
      render json: { price_at_time: price }
    else
      render json: { error: "Price not found" }, status: :bad_request
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:company_name, :stock_symbol, :price_at_time, :quantity, :total_amount, :transaction_type)
  end

  def record_not_found
    redirect_to transactions_path, alert: "Transaction does not exist."
  end
end
