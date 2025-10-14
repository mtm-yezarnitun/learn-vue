class EventNotificationsChannel < ApplicationCable::Channel
  def subscribed
    user_id = params[:user_id]

    if User.exists?(user_id)
      stream_from "user_#{user_id}_notifications"
    else
      reject
    end
  end
end
