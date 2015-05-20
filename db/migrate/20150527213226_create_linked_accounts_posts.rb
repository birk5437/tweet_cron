class CreateLinkedAccountsPosts < ActiveRecord::Migration
  def change
    create_table :linked_accounts_posts, id: false do |t|
      t.integer :post_id
      t.integer :linked_account_id
    end
  end
end
