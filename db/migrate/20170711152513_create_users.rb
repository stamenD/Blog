class CreateUsers < ActiveRecord::Migration[5.0]
  def change
  	create_table :users do |t|
  	  t.string :username , null: false
  	  t.string :password_hash , null: false
  	  t.string :mail , null: false
  	  t.string :token
  	  t.integer :isAdmin
  	end  	
  end
end
