class AddNameAndTypeToLinkedAccounts < ActiveRecord::Migration
  def change
    add_column :linked_accounts, :name, :string
    add_column :linked_accounts, :type, :string
  end
end
