class AnnouncementSchedulerJob
  include Sidekiq::Job
  sidekiq_options retry: false

  def perform(announcement_id)
    announcement = Announcement.find_by(id: announcement_id)
    return unless announcement

    now = Time.current

    if now >= announcement.end_time
      announcement.update(active: false)
    elsif now >= announcement.start_time
      announcement.update(active: true)
      AnnouncementSchedulerJob.set(wait_until: announcement.end_time).perform_async(announcement.id)
    else
      AnnouncementSchedulerJob.set(wait_until: announcement.start_time).perform_async(announcement.id)
    end
  end
end
