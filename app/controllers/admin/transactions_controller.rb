class Admin::TransactionsController < Admin::ApplicationController
  before_action :set_transaction, only: [:show]
  
  # Admin Story 7: See all transactions
  def index
    @q = Transaction.for_traders.ransack(params[:q])
    @transactions = @q.result.recent.includes(:user)
    
    @stats = transaction_stats
  end
  
  def show
    @trader = @transaction.user
  end
  
  private
  
  def set_transaction
    @transaction = Transaction.for_traders.find(params[:id])
  end

  def transaction_stats
    {
      total_transactions: @transactions.count,
      total_buy_transactions: Transaction.for_traders.buy_orders.count,
      total_sell_transactions: Transaction.for_traders.sell_orders.count,
      total_transaction_value: Transaction.for_traders.sum(:total_amount)
    }
  end
end