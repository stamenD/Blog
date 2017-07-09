class Post < ActiveRecord::Base
  validates :theme, presence: true

  def changeStutus
    self.isActive = if self.isActive == 1 then 0 else 1 end
  end

end