require 'bcrypt'
require_relative 'post'

class User < ActiveRecord::Base
  include BCrypt

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
    @pass ||= Password.new(self.password_hash)
  end

  def password=(new_password)
    @pass = Password.create(new_password)
    self.password_hash = @pass
  end

  def changeStutus
    self.isAdmin = if self.isAdmin == 1 then 0 else 1 end
  end

end