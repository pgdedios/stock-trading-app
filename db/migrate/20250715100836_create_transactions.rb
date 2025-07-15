class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.string :company_name,     null: false
      t.string :stock_symbol,     null: false
      t.string :transaction_type, null: false
      t.integer :quantity,        null: false
      t.decimal :price_at_time,   null: false, precision: 15, scale: 2
      t.decimal :total_amount,    null: false, precision: 15, scale: 2
      t.references :user,         null: false, foreign_key: true

      t.timestamps
    end
  end
end
