class Post < ApplicationRecord
  belongs_to :user , optional: true 

  validates :title, presence: true
  validates :body, presence: true

  has_many :comments, dependent: :destroy

  delegate :email, to: :user, prefix: true
end
