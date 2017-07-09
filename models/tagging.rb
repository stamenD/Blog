require_relative 'tag'
require_relative 'post'


class Tagging < ActiveRecord::Base
  belongs_to :post
  belongs_to :tag
end