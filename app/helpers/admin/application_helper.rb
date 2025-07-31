module Admin::ApplicationHelper
  # Form helpers for trader forms
  def form_url(trader)
    trader.persisted? ? admin_trader_path(trader) : admin_traders_path
  end

  def form_method(trader)
    trader.persisted? ? :patch : :post
  end

  def cancel_path(trader)
    trader.persisted? ? admin_trader_path(trader) : admin_traders_path
  end

  # Status helpers
  def trader_status_class(trader)
    if trader.can_trade?
      "text-green-600"
    elsif trader.confirmed_at.present?
      "text-yellow-600"
    else
      "text-red-600"
    end
  end

  def transaction_type_badge_class(transaction)
    transaction.transaction_type == "buy" ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800"
  end

  # Number formatting helpers
  def format_currency(amount)
    number_to_currency(amount, precision: 2)
  end

  def format_percentage(value)
    number_to_percentage(value, precision: 1)
  end

  # Date formatting helpers
  def format_date(date)
    date&.strftime("%B %d, %Y")
  end

  def format_datetime(datetime)
    datetime&.strftime("%m/%d/%Y %I:%M %p")
  end

  def format_short_date(date)
    date&.strftime("%m/%d/%Y")
  end
end
