class CreateTaggings < ActiveRecord::Migration[5.0]
  def change
  	create_table :taggings do |t|
  	  t.references :post
  	  t.references :tag
    end  	
  end
end
