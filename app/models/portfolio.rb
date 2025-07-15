class Portfolio < ApplicationRecord
  belongs_to :user

  # enum transaction_type: { buy: 'buy', sell: 'sell' }   #Paolo >> To uncomment later.
  # validates :role, inclusion: { in: transaction_types.keys }       #Paolo >> To uncomment later.
end
