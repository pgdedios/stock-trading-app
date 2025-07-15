class CreatePortfolios < ActiveRecord::Migration[7.2]
  def change
    create_table :portfolios do |t|
      t.string :company_name,   null: false
      t.string :stock_symbol,   null: false
      t.integer :quantity,      null: false
      t.decimal :current_price, null: false, precision: 15, scale: 2
      t.decimal :total_amount,  null: false, precision: 15, scale: 2
      t.references :user,       null: false, foreign_key: true

      t.timestamps
    end
  end
end
