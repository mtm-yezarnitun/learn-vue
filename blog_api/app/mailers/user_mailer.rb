class UserMailer < ApplicationMailer
  default from: 'no-reply@yourapp.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://localhost:5173'
    mail(to: @user.email, subject: 'Welcome to My Awesome App')
  end

  def event_reminder(user, event)
    @user = user
    @event = event
    mail(to: @user.email, subject: 'Remainder : #{event.title}')
  end

  def send_calendar_pdf(user, pdf_data)
    @user = user

    attachments['all_events.pdf'] = { mime_type: 'application/pdf', content: pdf_data }

    mail(to: user.email, subject: 'Your All Events PDF')
  end
end
