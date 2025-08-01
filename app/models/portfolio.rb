class Portfolio < ApplicationRecord
  belongs_to :user

  validates :company_name, :stock_symbol, :quantity, :current_price, :total_amount, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  scope :for_stock, ->(symbol) { where(stock_symbol: symbol) }

  def self.ransackable_attributes(auth_object = nil)
    # Only allow safe transaction attributes to be searched
    [ "company_name", "stock_symbol" ]
  end

  def self.ransackable_associations(auth_object = nil)
    # Allow searching through user association (for trader info)
    [ "user" ]
  end
end
