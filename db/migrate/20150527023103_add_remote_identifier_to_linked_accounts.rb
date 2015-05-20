class AddRemoteIdentifierToLinkedAccounts < ActiveRecord::Migration
  def change
    add_column :linked_accounts, :remote_identifier, :string
  end
end
