class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string :stripe_id
      t.string :status
      t.datetime :paid_at

      t.timestamps
    end
    add_index :orders, :stripe_id, unique: true
  end
end
