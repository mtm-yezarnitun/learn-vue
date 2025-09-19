class Post < ApplicationRecord
  belongs_to :user , optional: true 

  validates :title, presence: true
  validates :body, presence: true

  has_many :comments, dependent: :destroy

  def user_email
    user.email
  end
end
