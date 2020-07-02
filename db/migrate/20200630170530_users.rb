class Users < ActiveRecord::Migration[6.0]
  def self.up
    create_table :users do |t|
      t.column :name, :string
      t.column :personal_website, :string
      t.column :shortened_url, :string
      t.column :profile, :text
    end
  end

  def self.down
    drop_table :users
  end
end
