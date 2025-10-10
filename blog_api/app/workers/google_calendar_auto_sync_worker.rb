class GoogleCalendarAutoSyncWorker
  include Sidekiq::Worker

  def perform
    redis = Redis.new

    User.where.not(google_refresh_token: nil).find_each do |user|
      Rails.logger.info "Auto-sync started for user #{user.id}"

      service = user.google_calendar_service
      next unless service

      begin
        events = service.list_events(
          'primary',
          single_events: true,
          order_by: 'startTime',
          time_min: 1.year.ago.rfc3339
        )
      formatted_events = events.items.map { |event| calendar_event_to_json(event) }
      redis.set("user:#{user.id}:events", formatted_events.to_json)
        
        Rails.logger.info "✅ Synced #{events.items.count} events for user #{user.id}"

      rescue Google::Apis::AuthorizationError => e
        Rails.logger.error "⚠️ Authorization failed for user #{user.id}: #{e.message}"
        user.update(google_access_token: nil, google_refresh_token: nil, google_token_expires_at: nil)
      rescue => e
        Rails.logger.error "❌ Sync error for user #{user.id}: #{e.message}"
      end
    end
  end

  private
    def calendar_event_to_json(event)
        processed_attendees = event.attendees&.map do |attendee|
          if attendee.respond_to?(:email)
            attendee.email
          elsif attendee.is_a?(String)
            attendee
          else
            attendee.to_s
          end
        end || []

        Rails.logger.info "Processed attendees: #{processed_attendees.inspect}"
        {
          id: event.id,
          title: event.summary,
          description: event.description,
          location: event.location,
          attendees: event.attendees&.map { |a| a.email } || [],
          colorId: event.color_id,
          recurrence: event.recurrence,
          start_time: event.start&.date_time,
          end_time: event.end&.date_time,
          html_link: event.html_link
        }
    end
end
