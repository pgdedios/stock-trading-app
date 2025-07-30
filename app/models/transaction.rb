class Transaction < ApplicationRecord
  belongs_to :user

  after_create :process_transaction

  validates :company_name, :stock_symbol, :quantity, :price_at_time, :total_amount, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  attribute :quantity, default: 0

  # Scopes
  scope :for_traders, -> { joins(:user).where(users: { is_admin: false }) }
  scope :buy_orders, -> { where(transaction_type: "buy") }
  scope :sell_orders, -> { where(transaction_type: "sell") }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_stock, ->(symbol) { where(stock_symbol: symbol) }
  scope :for_trader, ->(trader_id) { where(user_id: trader_id) }
  scope :between_dates, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Ransack configuration - Define which attributes can be searched
  def self.ransackable_attributes(auth_object = nil)
    # Only allow safe transaction attributes to be searched
    [ "company_name", "stock_symbol", "transaction_type", "quantity", "price_at_time", "total_amount", "created_at", "updated_at", "id", "user_id" ]
  end

  def self.ransackable_associations(auth_object = nil)
    # Allow searching through user association (for trader info)
    [ "user" ]
  end

  def buy?
    transaction_type == "buy"
  end

  def sell?
    transaction_type == "sell"
  end

  def profit_indicator
    buy? ? "+" : "-"
  end

  attribute :quantity, default: 0

  private

  def process_transaction
    ActiveRecord::Base.transaction do
      case transaction_type
      when "buy"
        process_buy
      when "sell"
        process_sell
      else
        raise ArgumentError, "Invalid transaction type: #{transaction_type}"
      end
    end
  rescue => e
    Rails.logger.error("Transaction processing failed: #{e.message}")
    errors.add(:base, "#{e.message}")
    raise ActiveRecord::Rollback
  end

  def process_buy
    raise "Insufficient balance" if user.balance < total_amount

    update_portfolio_for_buy
    user.update!(balance: user.balance - total_amount)
  end

  def process_sell
    portfolio = user.portfolios.find_by(stock_symbol: stock_symbol)
    raise "Cannot sell more shares than owned" if portfolio.nil? || portfolio.quantity < quantity

    update_portfolio_for_sell(portfolio)
    user.update!(balance: user.balance + total_amount)
  end

  def update_portfolio_for_buy
    portfolio = user.portfolios.find_by(stock_symbol: stock_symbol)
    if portfolio.nil?
      portfolio = user.portfolios.new(stock_symbol: stock_symbol)
    end

    portfolio.company_name = company_name
    portfolio.quantity = (portfolio.quantity || 0) + quantity
    portfolio.total_amount = (portfolio.total_amount || 0) + total_amount
    portfolio.current_price = price_at_time
    portfolio.save!
  end

  def update_portfolio_for_sell(portfolio)
    portfolio.quantity -= quantity
    portfolio.total_amount -= total_amount
    portfolio.current_price = price_at_time

    portfolio.quantity <= 0 ? portfolio.destroy : portfolio.save!
  end
end
