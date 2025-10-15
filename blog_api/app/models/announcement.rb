class Announcement < ApplicationRecord
  scope :active, -> { where(active: true).where("start_time <= ? AND end_time >= ?", Time.current, Time.current) }
  validates :message, :start_time, :end_time, presence: true
end
