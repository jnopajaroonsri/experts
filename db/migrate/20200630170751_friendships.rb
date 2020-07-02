class Friendships < ActiveRecord::Migration[6.0]
  def self.up
    create_table :friendships do |t|
      t.integer :user_id
      t.integer :friend_id
    end
  end
  def self.down
    drop_table :friendships
  end
end
