class ExportPdfEmailWorker
  include Sidekiq::Worker

  def perform(user_id, pdf_data,filter)
    user = User.find(user_id)
    decoded_pdf = Base64.decode64(pdf_data)
    UserMailer.send_calendar_pdf(user, decoded_pdf,filter).deliver_now
  end
end
