require 'csv'

class ImportEventsJob
  include Sidekiq::Job

  def perform(user_id, file_path)
    user = User.find(user_id)
    service = user.google_calendar_service

    unless File.exist?(file_path)
      Rails.logger.error("File not found: #{file_path}")
      return
    end
    
    CSV.foreach(file_path, headers: true) do |row|
        start_time_str = row["Start Time"]&.strip
        end_time_str   = row["End Time"]&.strip

        attendees_emails = row["Attendees"]&.split(',')&.map(&:strip)&.reject(&:blank?) || []
        attendees = attendees_emails.map { |email| Google::Apis::CalendarV3::EventAttendee.new(email: email) }

        start_time = Time.find_zone("Asia/Yangon").parse(start_time_str)
        end_time   = Time.find_zone("Asia/Yangon").parse(end_time_str)
              
        event = Google::Apis::CalendarV3::Event.new(
            summary: row["Title"],
            description: row["Description"],
            location: row["Location"],
            start: Google::Apis::CalendarV3::EventDateTime.new(date_time: start_time.rfc3339, time_zone: "Asia/Yangon"),
            end: Google::Apis::CalendarV3::EventDateTime.new(date_time: end_time.rfc3339, time_zone: "Asia/Yangon"),
            attendees: attendees
        )
        service.insert_event("primary", event)

    end
  end
end
