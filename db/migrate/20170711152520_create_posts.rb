class CreatePosts < ActiveRecord::Migration[5.0]
  def change
  	create_table :posts do |t|
  	  t.string :subject , null: false
  	  t.text :theme , null: false
  	  t.string :imagePath
  	  t.integer :isActive
  	  t.string :language
      t.datetime :published

  	  
      t.belongs_to :user 	  
  	end
  end
end
