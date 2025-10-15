class AnnouncementSchedulerJob
  include Sidekiq::Job
  sidekiq_options retry: false

  def perform(announcement_id)
    announcement = Announcement.find_by(id: announcement_id)
    return unless announcement

    if Time.current >= announcement.end_time
      announcement.update(active: false)
    elsif Time.current >= announcement.start_time
      announcement.update(active: true)
      AnnouncementSchedulerJob.set(wait_until: announcement.end_time).perform_async(announcement.id)
    end
  end
end
