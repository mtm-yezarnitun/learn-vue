class UserMailer < ApplicationMailer
  default from: 'no-reply@yourapp.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://localhost:5173'
    mail(to: @user.email, subject: 'Welcome to My Awesome App')
  end

  def event_reminder(user , event)
    @user = user
    @event = event
    mail(to: @user.email, subject: 'Remainder : #{event.title}')
  end

end
