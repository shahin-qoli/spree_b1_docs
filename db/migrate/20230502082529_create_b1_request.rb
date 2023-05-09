class CreateB1Request < ActiveRecord::Migration[4.2]
  def change
    create_table :b1_requests do |t|
      t.references :order
      t.text :response
      t.text :request
      t.boolean :is_success
      t.timestamps
    end
  end
end
