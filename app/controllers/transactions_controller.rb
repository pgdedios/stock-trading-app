class TransactionsController < ApplicationController
  before_action :authenticate_user!
  def index
    @transactions = current_user.transactions.order(created_at: :desc)
  end

  def buy
    @transaction = Transaction.new
    @companies = JSON.parse(File.read(Rails.root.join("lib/assets/data/companies.json")))
  end

  def sell
    @transaction = Transaction.new
    @companies = current_user.portfolios.map(&:attributes)
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


  def create
    @transaction = current_user.transactions.build(transaction_params)

    if @transaction.save
      redirect_to transactions_path, notice: "Transaction completed!"
    else
      flash[:alert] = @transaction.errors.full_messages.to_sentence
      if transaction_params[:transaction_type] == "buy"
        @companies = JSON.parse(File.read(Rails.root.join("lib/assets/data/companies.json")))
        render :buy, status: :unprocessable_entity
      else
        @companies = current_user.portfolios.map(&:attributes)
        render :sell, status: :unprocessable_entity
      end
    end
  end

  private

  def transaction_params
  params.require(:transaction).permit(:company_name, :stock_symbol, :price_at_time, :quantity, :total_amount, :transaction_type)
  end
end
