class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :type
      t.text :text
      t.string :tweet_id
      t.datetime :published_at
      t.boolean :published, null: false, default: false
      t.timestamps
    end
  end
end
