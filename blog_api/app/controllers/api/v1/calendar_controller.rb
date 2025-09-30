module Api::V1
  class CalendarController < ApplicationController
    before_action :authenticate_user!

    def events
      service = current_user.google_calendar_service

      if service.nil?
        if current_user.refresh_google_token!
          service = current_user.google_calendar_service
        end
      end

      if service.nil?
        return render json: { error: 'Google Calendar not connected' }, status: :unauthorized
      end

      events = service.list_events(
        'primary',
        max_results: 10,
        single_events: true,
        order_by: 'startTime',
        time_min: DateTime.now.rfc3339
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
        user_timezone = 'Asia/Yangon'
        start_time = Time.find_zone(user_timezone).parse(params[:start_time])
        end_time = Time.find_zone(user_timezone).parse(params[:end_time])

        if end_time <= start_time
          return render json: { error: 'End time must be after start time' }, status: :bad_request
        end

        event = Google::Apis::CalendarV3::Event.new(
          summary: params[:title],
          description: params[:description],
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
        render json: { event: calendar_event_to_json(result) }

      rescue ArgumentError => e
        render json: { error: 'Invalid date format' }, status: :bad_request
      rescue Google::Apis::ClientError => e
        render json: { error: 'Google Calendar error: ' + e.message }, status: :bad_request
      rescue => e
        render json: { error: 'Failed to create event' }, status: :internal_server_error
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
        start_time: event.start&.date_time,
        end_time: event.end&.date_time,
        html_link: event.html_link
      }
    end
  end
end
