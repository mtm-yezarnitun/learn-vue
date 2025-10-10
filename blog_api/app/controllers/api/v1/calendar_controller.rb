module Api::V1
  class CalendarController < ApplicationController
    before_action :authenticate_user!
    after_action :update_cached_events, only: [:create_event, :update, :destroy]

    def cached_events
      redis = Redis.new
      data = redis.get("user:#{current_user.id}:events")

      if data 
        render json: { events: JSON.parse(data)}

      else
        service = current_user.google_calendar_service
        if service
          begin
            events = service.list_events(
              'primary',
              single_events: true,
              order_by: 'startTime',
              time_min: 1.year.ago.rfc3339
            )

            formatted = events.items.map { |e| calendar_event_to_json(e) }
            Redis.new.set("user:#{current_user.id}:events", formatted.to_json)
            Rails.logger.info "✅ Redis cached for user #{current_user.id}"
            render json: { events: formatted }  
          rescue => e
            Rails.logger.error "⚠️ Failed to Redis cache: #{e.message}"
            render json: { events: [], error: 'Failed to fetch events from Google Calendar' }, status: :internal_server_error
          end
        else
          render json: { events: [], error: 'Google Calendar not connected' }, status: :unauthorized
        end

      end

    end

    def events
      service = current_user.google_calendar_service
      if service.nil? 
        if current_user.refresh_google_token
          service = current_user.google_calendar_service
        end
      end

      if service.nil?
        return render json: { error: 'Google Calendar not connected' }, status: :unauthorized
      end
      
      events = service.list_events(
        'primary',
        single_events: true,
        order_by: 'startTime',
        time_min: 1.year.ago.rfc3339
      )
      
      formatted_events = events.items.map { |event| calendar_event_to_json(event) }
      Redis.new.set("user:#{current_user.id}:events", formatted_events.to_json)

      render json: { events: formatted_events }
    rescue Google::Apis::AuthorizationError => e
      Rails.logger.error "Calendar authorization error: #{e.message}"
      render json: { error: 'Calendar access expired. Please reconnect.' }, status: :unauthorized
    rescue => e
      Rails.logger.error "Calendar error: #{e.message}"
      render json: { error: 'Failed to fetch calendar events' }, status: :internal_server_error
    end

    def create_event
      unless current_user.google_access_token
        return render json: { error: 'Google Calendar not connected' }, status: :unauthorized
      end

      service = current_user.google_calendar_service
      if service.nil?
        return render json: { error: 'Failed to initialize calendar service' }, status: :internal_server_error
      end

      begin

        recurrence_rule = params[:recurrence].presence
        recurrence_rule = nil if recurrence_rule == "null"

        attendees_emails = params[:attendees]&.split(",")&.map(&:strip)&.reject(&:blank?) || []
        attendees = attendees_emails.map { |email| Google::Apis::CalendarV3::EventAttendee.new(email: email) }
        
        user_timezone = 'Asia/Yangon'
        start_time = Time.find_zone(user_timezone).parse(params[:start_time])
        end_time = Time.find_zone(user_timezone).parse(params[:end_time])

        if end_time <= start_time
          return render json: { error: 'End time must be after start time' }, status: :bad_request
        end

        event = Google::Apis::CalendarV3::Event.new(
          summary: params[:title],
          description: params[:description],
          location: params[:location], 
          color_id: params[:colorId],
          start: Google::Apis::CalendarV3::EventDateTime.new(
            date_time: start_time.rfc3339,
            time_zone: user_timezone
          ),
          end: Google::Apis::CalendarV3::EventDateTime.new(
            date_time: end_time.rfc3339,
            time_zone: user_timezone
          ),
          attendees:  attendees

        )
        event.recurrence = [recurrence_rule] if recurrence_rule

        result = service.insert_event('primary', event)
        
        render json: { event: calendar_event_to_json(result) }

        redis = Redis.new
        redis.del("user:#{current_user.id}:events")
        
      rescue ArgumentError => e
        render json: { error: 'Invalid date format' }, status: :bad_request
      rescue Google::Apis::ClientError => e
        render json: { error: 'Google Calendar error: ' + e.message }, status: :bad_request
      rescue => e
        Rails.logger.error "Create event failed: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}"
        render json: { error: 'Failed to create event' }, status: :internal_server_error
      end
    end

    def update
      unless current_user.google_access_token
        return render json: { error: 'Google Calendar not connected' }, status: :unauthorized
      end

      service = current_user.google_calendar_service
      if service.nil?
        return render json: { error: 'Failed to initialize calendar service' }, status: :internal_server_error
      end

      begin
        user_timezone = 'Asia/Yangon'
        
        start_time = if params[:start_time].present?
          Time.find_zone(user_timezone).parse(params[:start_time])
        end

        end_time = if params[:end_time].present?
          Time.find_zone(user_timezone).parse(params[:end_time])
        end

        if start_time && end_time && end_time <= start_time
          return render json: { error: 'End time must be after start time' }, status: :bad_request
        end
          
        existing_event = service.get_event('primary', params[:id])
        
        existing_event.summary = params[:title] if params[:title].present?
        existing_event.description = params[:description] if params.key?(:description)
        existing_event.location = params[:location] if params.key?(:location)
        existing_event.color_id = params[:colorId] if params.key?(:colorId)
        
        if params.key?(:attendees)
          attendees_emails = params[:attendees]&.split(",")&.map(&:strip)&.reject(&:blank?) || []
          existing_event.attendees = attendees_emails.map { |email| Google::Apis::CalendarV3::EventAttendee.new(email: email) }
        end
        
        if start_time
          existing_event.start = Google::Apis::CalendarV3::EventDateTime.new(
            date_time: start_time.rfc3339,
            time_zone: user_timezone
          )
        end       

        if end_time
          existing_event.end = Google::Apis::CalendarV3::EventDateTime.new(
            date_time: end_time.rfc3339,
            time_zone: user_timezone
          )
        end

        result = service.update_event('primary', params[:id], existing_event)

        redis = Redis.new
        redis.del("user:#{current_user.id}:events")

        render json: { event: calendar_event_to_json(result) }

      rescue ArgumentError => e
        render json: { error: 'Invalid date format' }, status: :bad_request
      rescue Google::Apis::ClientError => e
        if e.status_code == 404
          render json: { error: 'Event not found' }, status: :not_found
        else
          render json: { error: 'Google Calendar error: ' + e.message }, status: :bad_request
        end
      rescue => e
        Rails.logger.error "Calendar update error: #{e.message}"
        render json: { error: 'Failed to update event' }, status: :internal_server_error
      end
    end

    def destroy
      unless current_user.google_access_token
        return render json: { error: 'Google Calendar not connected' }, status: :unauthorized
      end

      service = current_user.google_calendar_service
      if service.nil?
        return render json: { error: 'Failed to initialize calendar service' }, status: :internal_server_error
      end

      begin
        service.delete_event('primary', params[:id])

        redis = Redis.new
        redis.del("user:#{current_user.id}:events")

        render json: { message: 'Event deleted successfully' }
      rescue Google::Apis::ClientError => e
        render json: { error: 'Event not found' }, status: :not_found
      rescue => e
        render json: { error: 'Failed to delete event' }, status: :internal_server_error
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

      def update_cached_events
        service = current_user.google_calendar_service
        return unless service

        begin
          events = service.list_events(
            'primary',
            single_events: true,
            order_by: 'startTime',
            time_min: 1.year.ago.rfc3339
          )

          formatted = events.items.map { |e| calendar_event_to_json(e) }

          Redis.new.set("user:#{current_user.id}:events", formatted.to_json)
          Rails.logger.info "✅ Redis cache refreshed for user #{current_user.id}"
        rescue => e
          Rails.logger.error "⚠️ Failed to refresh Redis cache: #{e.message}"
        end
      end
  end
end
