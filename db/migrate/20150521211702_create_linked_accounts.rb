class CreateLinkedAccounts < ActiveRecord::Migration
  def change
    create_table :linked_accounts do |t|
      t.references :user
      t.timestamps
    end
    add_column :posts, :linked_account_id, :integer
  end
end
