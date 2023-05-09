class AddB1DocNumToOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_orders, :b1_doc_entry, :integer
    add_column :spree_orders, :b1_doc_num, :integer
    add_column :spree_payments, :b1_doc_num, :integer
    add_column :spree_payments, :b1_doc_entry, :integer
    add_column :spree_orders, :b1_documented, :boolean
    add_column :spree_payments, :b1_documented, :boolean
  end
end
