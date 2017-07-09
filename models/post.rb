class Post < ActiveRecord::Base
  validates :theme, presence: true
  has_many :taggings , dependent: :destroy
  has_many :tags, through: :taggings
 
  def changeStutus
    self.isActive = if self.isActive == 1 then 0 else 1 end
  end

  def all_tags= names
    self.tags=names.split(',').map { |e|  Tag.where(name: e).first_or_create! }
  end

  def all_tags
    self.tags.map(&:name).join(",")
  end

  def self.tagged_with(name)
    Tag.find_by_name(name).posts
  end
end