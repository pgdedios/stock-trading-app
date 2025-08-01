class Admin::TradersController < Admin::ApplicationController
  before_action :set_trader, only: [ :show, :edit, :update, :approve, :reject ]

  # Admin Story 4: See all traders
  def index
    @q = User.traders.ransack(params[:q])
    @traders = @q.result.order(:created_at)
  end

  # Admin Story 5: Page for pending trader signups
  def pending
    @pending_traders = User.traders.pending.recent
  end

  # Admin Story 3: Show individual trader details
  def show
    @trader_stats = trader_stats
    @trader_transactions = @trader.transactions.recent.limit(10)
    @trader_portfolios = @trader.portfolios.order(:created_at)
  end

  # Admin Story 1: Create new traders
  def new
    @trader = User.new
  end

  def create
    @trader = build_new_trader
    if @trader.save
      redirect_to admin_trader_path(@trader), notice: "Trader was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Admin Story 2: Edit Existing Traders
  def edit; end

  def update
    if @trader.update(trader_params_for_update)
      redirect_to admin_trader_path(@trader), notice: "Trader was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Admin Story 6: Approve and Reject Traders
  def approve
    if @trader.update(is_approve: true)
      @trader.send_approval_notification
      redirect_back(fallback_location: admin_traders_path, notice: "Trader has been approved.")
    else
      redirect_back(fallback_location: admin_traders_path, alert: "Failed to approve trader.")
    end
  end

  def reject
    if @trader.update(is_approve: false)
      @trader.send_rejection_notification
      redirect_back(fallback_location: admin_traders_path, notice: "Trader has been rejected.")
    else
      redirect_back(fallback_location: admin_traders_path, alert: "Failed to reject trader.")
    end
  end

  private

  def set_trader
    @trader = User.traders.find(params[:id])
  end

  def trader_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :balance)
  end

  def trader_params_for_update
    permitted_params = params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :balance)
    # Remove password fields if they're blank (to keep existing password)
    if permitted_params[:password].blank?
      permitted_params.delete(:password)
      permitted_params.delete(:password_confirmation)
    end

    permitted_params
  end

  def build_new_trader
    trader = User.new(trader_params)
    trader.is_admin = false
    trader.is_approve = true
    trader.created_by_admin = true
    trader
  end

  def trader_stats
    {
      total_transactions: @trader.total_trades,
      total_buy_transactions: @trader.buy_transactions_count,
      total_sell_transactions: @trader.sell_transactions_count,
      current_balance: @trader.balance,
      portfolio_value: @trader.portfolio_value
    }
  end
end
