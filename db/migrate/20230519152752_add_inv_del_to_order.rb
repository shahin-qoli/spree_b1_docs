class AddInvDelToOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_orders, :delivery_b1_doc_entry, :integer
    add_column :spree_orders, :delivery_b1_doc_num, :integer
    add_column :spree_orders, :invoice_b1_doc_entry, :integer
    add_column :spree_orders, :invoice_b1_doc_num, :integer  
  end
end
