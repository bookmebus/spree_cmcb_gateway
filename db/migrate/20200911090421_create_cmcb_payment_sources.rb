class CreateCmcbPaymentSources < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_cmcb_payment_sources do |t|
      t.integer :payment_method_id
      t.integer :user_id

      t.string :status
      t.string :reference_number
      t.string :payment_method_name
    end
  end
end
