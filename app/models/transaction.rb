class Transaction < ApplicationRecord
  belongs_to :user

  after_create :process_transaction

  validates :company_name, :stock_symbol, :quantity, :price_at_time, :total_amount, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

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
    # Optionally, you can add error tracking or notifications here
    # e.g., Sentry.capture_exception(e)
    errors.add(:base, "Transaction failed: #{e.message}")
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
    portfolio = user.portfolios.find_or_initialize_by(stock_symbol: stock_symbol)
    portfolio.assign_attributes(
      company_name: company_name,
      quantity: (portfolio.quantity || 0) + quantity,
      total_amount: (portfolio.total_amount || 0) + total_amount,
      current_price: price_at_time
    )
    portfolio.save!
  end
  def update_portfolio_for_sell(portfolio)
    portfolio.quantity -= quantity
    portfolio.total_amount -= total_amount
    portfolio.current_price = price_at_time

    portfolio.quantity <= 0 ? portfolio.destroy : portfolio.save!
  end
end
