class AddPostAtToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :post_at, :datetime
  end
end
