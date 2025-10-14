class EventNotificationJob
  include Sidekiq::Job
  sidekiq_options retry: false

  CHECK_INTERVAL = 60          
  NOTIFY_START_MINUTES = 5    

  def perform
    redis = Redis.new
    now = Time.zone.now

    User.find_each do |user|
      data = redis.get("user:#{user.id}:events")
      next unless data

      events = JSON.parse(data)

      events.each do |event|
        start_time = Time.zone.parse(event["start_time"]) rescue nil
        next unless start_time

        seconds_to_start = start_time.to_i - now.to_i
        minutes_left = (seconds_to_start / 60.0).ceil
        next if minutes_left > NOTIFY_START_MINUTES || minutes_left <= 0

        notified_key = "user:#{user.id}:event:#{event['id']}:#{minutes_left}"
        next if redis.exists?(notified_key)

        message = "Event '#{event['title']}' starts in #{minutes_left} minute#{'s' if minutes_left > 1}!"

        ActionCable.server.broadcast(
          "user_#{user.id}_notifications",
          { message: message }
        )

        redis.setex(notified_key, CHECK_INTERVAL + 5, true)
      end
    end
  end
end
