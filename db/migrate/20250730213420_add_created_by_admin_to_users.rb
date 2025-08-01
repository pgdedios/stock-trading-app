class AddCreatedByAdminToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :created_by_admin, :boolean, default: false
  end
end
