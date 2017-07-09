require_relative 'tagging'
require_relative 'post'

class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :posts, through: :taggings

  def self.clear_unused
    self.all.map { |e| e.destroy if e.posts.empty? }
  end
end