class CreateComments < ActiveRecord::Migration[5.0]
  def change
  	create_table :comments do |t|
  	  t.text :content
      t.datetime :published

      t.belongs_to :post
      t.belongs_to :user
    end
  end
end
