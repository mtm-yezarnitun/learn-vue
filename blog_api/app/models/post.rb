class Post < ApplicationRecord
  belongs_to :user , optional: true 

  validates :title, presence: true
  validates :body, presence: true

  def user_email
    user.email
  end
end
