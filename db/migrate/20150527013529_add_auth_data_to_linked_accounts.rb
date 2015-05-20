class AddAuthDataToLinkedAccounts < ActiveRecord::Migration
  def change
    add_column :linked_accounts, :auth_data, :text
  end
end
