require 'csv'
require 'redis'

class ImportEventsJob
  include Sidekiq::Job
  sidekiq_options retry: false

  def perform(user_id, file_path,job_key)
    user = User.find(user_id)
    service = user.google_calendar_service
    redis = Redis.new

    unless File.exist?(file_path)
      redis.set(job_key, { status: "error", message: "File not found" }.to_json)
      return
    end

    rows = []
    errors = []

    CSV.foreach(file_path, headers: true).with_index(2) do |row, line_num|
      begin
        start_time = Time.zone.parse(row["Start Time"])
        end_time   = Time.zone.parse(row["End Time"])
        raise "Start or End time missing" if start_time.nil? || end_time.nil?

        attendees_emails = row["Attendees"]&.split(',')&.map(&:strip)&.reject(&:blank?) || []
        attendees = attendees_emails.map { |email| Google::Apis::CalendarV3::EventAttendee.new(email: email) }

        rows << {
          summary: row["Title"],
          description: row["Description"],
          location: row["Location"],
          start_time: start_time,
          end_time: end_time,
          attendees: attendees
        }
      rescue => e
        errors << "Row #{line_num}: #{e.message}"
      end
    end

    if errors.any?
      redis.set(job_key, { status: "error", message: "Import aborted. Found errors.", errors: errors }.to_json)
      Rails.logger.error("🚫 Import aborted due to invalid rows:\n#{errors.join("\n")}")
      return
    end

    begin
      rows.each do |data|
        event = Google::Apis::CalendarV3::Event.new(
          summary: data[:summary],
          description: data[:description],
          location: data[:location],
          start: Google::Apis::CalendarV3::EventDateTime.new(date_time: data[:start_time].rfc3339, time_zone: "Asia/Yangon"),
          end:   Google::Apis::CalendarV3::EventDateTime.new(date_time: data[:end_time].rfc3339, time_zone: "Asia/Yangon"),
          attendees: data[:attendees]
        )
        service.insert_event("primary", event)
      end

      redis.set(job_key, { status: "ok", message: "All events imported successfully!" }.to_json)
      Rails.logger.info("✅ Import successful: #{rows.size} events created")

    rescue => e
      redis.set(job_key, { status: "error", message: "Import failed during event creation: #{e.message}" }.to_json)
      Rails.logger.error("❌ Import failed during API insertion")

    end
  end
end
