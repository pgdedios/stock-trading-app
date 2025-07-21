class Portfolio < ApplicationRecord
  belongs_to :user

  validates :company_name, :stock_symbol, :quantity, :current_price, :total_amount, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }


  # enum transaction_type: { buy: 'buy', sell: 'sell' }   #Paolo >> To uncomment later.
  # validates :role, inclusion: { in: transaction_types.keys }       #Paolo >> To uncomment later.
end
