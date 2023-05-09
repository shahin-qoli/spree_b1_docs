class AddB1CodeToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_users, :b1_code, :string
  end
end
