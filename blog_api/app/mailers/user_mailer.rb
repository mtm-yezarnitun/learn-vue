class UserMailer < ApplicationMailer
  default from: 'no-reply@yourapp.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://localhost:5173'
    mail(to: @user.email, subject: 'Welcome to My Awesome App')
  end

  def send_calendar_pdf(user , pdf_data,filter)
    @user = user
    attachments["#{filter}_Events.pdf"] = {
      mime_type: 'application/pdf',
      content: pdf_data  
    }
    mail(to: @user.email, subject: 'Events exported as PDF')
  end

  def send_calendar_csv(user, csv_data,filter) 
    @user = user

    if csv_data.nil?
      csv_data = "No Events found"
    end

    attachments["#{filter}_Events.csv"] = {
      mime_type: 'text/csv',
      content: csv_data
    }
    mail(to: @user.email, subject: 'Events exported as CSV')
  end

end
