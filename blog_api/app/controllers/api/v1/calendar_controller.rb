module Api::V1
  class CalendarController < ApplicationController
    before_action :authenticate_user!

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

      render json: { events: events.items || [] }
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
        recurrence = params[:recurrence].presence || params.dig(:calendar, :recurrence).presence
        recurrence = [recurrence] if recurrence.is_a?(String)
        recurrence = [] if recurrence.blank? 

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
          recurrence: recurrence,
          start: Google::Apis::CalendarV3::EventDateTime.new(
            date_time: start_time.rfc3339,
            time_zone: user_timezone
          ),
          end: Google::Apis::CalendarV3::EventDateTime.new(
            date_time: end_time.rfc3339,
            time_zone: user_timezone
          )
        )

        result = service.insert_event('primary', event)
        
        reminder_time = [start_time - 30.minutes, Time.current].max
        ReminderJob.set(wait_until: reminder_time).perform_later(current_user.id, result.id)

        render json: { event: calendar_event_to_json(result) }

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

        if result.start&.date_time
          new_start_time = result.start.date_time.to_time
          ReminderJob.set(wait_until: new_start_time - 30.minutes).perform_later(current_user.id, result.id)
        end

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
        render json: { message: 'Event deleted successfully' }
      rescue Google::Apis::ClientError => e
        render json: { error: 'Event not found' }, status: :not_found
      rescue => e
        render json: { error: 'Failed to delete event' }, status: :internal_server_error
      end
    end

    private
    def calendar_event_to_json(event)
      {
        id: event.id,
        title: event.summary,
        description: event.description,
        location: event.location,
        colorId: event.color_id,
        recurrence: event.recurrence,
        start_time: event.start&.date_time,
        end_time: event.end&.date_time,
        html_link: event.html_link
      }
    end
  end
end
