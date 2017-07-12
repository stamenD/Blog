require 'bcrypt'
require_relative 'post'
require_relative 'comment'

class User < ActiveRecord::Base
  include BCrypt

  has_many :comments , dependent: :destroy
  has_many :posts , dependent: :destroy

  validates :username,
  presence: true ,
  length: { in: 5..20 } , 
  format: { with: /\A\w+\z/,message: 'username must contain only letters and digits' } ,
  uniqueness: true

  # validates :password_hash
  # presence: true 
  
  validates :isAdmin,
  inclusion: { in: [0, 1] }

  def password
    116
    # @pass ||= Password.new(self.password_hash)
  end

  def password=(new_password)
    @pass = Password.create(new_password)
    self.password_hash = @pass
  end
end