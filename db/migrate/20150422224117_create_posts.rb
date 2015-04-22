class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :type
      t.text :text
      t.text :tweet_id
      t.timestamps
    end
  end
end
