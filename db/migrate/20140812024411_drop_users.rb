class DropUsers < ActiveRecord::Migration
  def change 
    drop_table :users
    drop_table :identities
  end
end
