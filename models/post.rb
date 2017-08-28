require_relative 'tagging'
require_relative 'tag'
require_relative 'comment'
require_relative 'user'

class Post < ActiveRecord::Base
  validates :theme, presence: true
  
  has_many :taggings , dependent: :destroy
  has_many :comments , dependent: :destroy
  has_many :tags, through: :taggings
  belongs_to :user

  def changeStutus
    self.isActive = if self.isActive == 1 then 0 else 1 end
  end

  def comments_number
    self.comments.size
  end

  def all_tags= names
    self.tags=names.split(',').select{|e| e.lstrip!; e.rstrip!; e.empty? == false }.map { |e|  Tag.where(name: e).first_or_create! }
  end

  def all_tags
    self.tags.map(&:name).join(",")
  end

  def self.tagged_with(name)
    arr = Tag.find_by_name(name)
    return [] if arr.class == NilClass
    arr.posts
  end

  def print
    str1 = (CGI.escapeHTML self.theme).to_s
    str2 = str1.dup
    
    str1.scan(/\*\*.+\*\*/) { |match| str2[match]="<b>"+match[2..-3]+"</b>"}
    str1 = str2.dup

    str1.scan(/\*.+\*/) { |match| str2[match]="<i>"+match[1..-2]+"</i>"}
    str1 = str2.dup

    str1.scan(/(?<nameUrl>\[.*\])(?<link>\(.*\))/) do |match| 
      link = "\"https://" + match[1][1..-2] + "\""
      linkText = match[0][1..-2]
      str2[match[0]+match[1]]="<a href=" + link + ">" + linkText + "</a>"
    end

    str1 = str2.dup
    str1.scan(/(?<times>^\#{1,6})(?<row>.*)/) do |match|
      size = match[0].length.to_s
      str2[match[0]+match[1]]="<h" + size + ">" + match[1] + "</h" + size + ">"
    end

    str1=str2.dup
    str1.scan(/\n+/){|match| str2[match]="<br>"}

    str2
  end
end