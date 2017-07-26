require 'bcrypt'
require "securerandom"
require_relative 'post'
require_relative 'comment'

class User < ActiveRecord::Base
  include BCrypt

  has_many :comments , dependent: :destroy
  has_many :posts , dependent: :destroy

  validates :username, presence: true 
  validates :username, length: { in: 5..20 ,message: "username's length must be between from 5 to 20 symbols" } 
  validates :username, format: { with: /\A\w+\z/,message: 'username must contain only letters and digits' }
  validates :username, uniqueness: true

  validates :password, presence: true
  # validates :password, length: { in: 5..20 ,message: "password length must be between from 5 to 20 symbols"}

  validates :mail, presence: true
  validates :mail, format: { with:  /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i,message: 'invalid email' }
  validates :mail, uniqueness: true

  def password
    @pass ||= Password.new(self.password_hash)
  end

  def password=(new_password)
    @pass = Password.create(new_password)
    self.password_hash = @pass
  end

end