class CalendarPdfJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    events = user.upcoming_events

    pdf_content = ApplicationController.renderer.render(
      template: 'calendar/pdf',
      layout: false,
      locals: { events: events, current_user: user }
    )

    UserMailer.send_calendar_pdf(user, pdf_content).deliver_now
  end
end
