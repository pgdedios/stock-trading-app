class RemoveIndexAddDefaultBalanceUser < ActiveRecord::Migration[7.2]
  def change
    remove_index :users, :first_name
    remove_index :users, :last_name
    remove_index :users, :balance
    remove_index :users, :is_admin
    remove_index :users, :is_approve
  end
end
