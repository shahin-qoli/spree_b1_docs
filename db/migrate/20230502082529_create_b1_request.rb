class CreateB1Request < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_b1_requests do |t|
      t.references :order
      t.text :response
      t.text :request
      t.boolean :is_success, default: false
      t.timestamps
    end
  end
end
