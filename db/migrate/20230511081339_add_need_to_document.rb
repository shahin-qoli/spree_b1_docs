class AddNeedToDocument < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_orders, :need_document, :boolean, default: true
  end
end
