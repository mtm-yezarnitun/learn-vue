class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  enum role: { user: 0, admin: 1 }

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

 

  def google_calendar_service
    unless google_access_token
      return nil
    end

    if token_expired?
      if google_refresh_token.present?
        if refresh_google_token
          Rails.logger.info "✅ Token refreshed successfully"
        else
          Rails.logger.error "❌ Token refresh failed"
          return nil
        end
      else
        update(google_access_token: nil, google_token_expires_at: nil)
        return nil
      end
    end

    begin
      service = Google::Apis::CalendarV3::CalendarService.new
      service.client_options.application_name = 'Your App'
      service.authorization = google_access_token
      
      service.list_calendar_lists(max_results: 1)
      
      service
      
    rescue Google::Apis::AuthorizationError => e
      update(google_access_token: nil, google_refresh_token: nil, google_token_expires_at: nil)
      nil
    rescue => e
      nil
    end
  end

  def refresh_google_token
    
    return false unless google_refresh_token
    
    begin
      uri = URI("https://oauth2.googleapis.com/token")
      
      response = Net::HTTP.post_form(uri, {
        client_id: ENV["GOOGLE_CLIENT_ID"],
        client_secret: ENV["GOOGLE_CLIENT_SECRET"],
        refresh_token: google_refresh_token,
        grant_type: "refresh_token"
      })
      
      if response.is_a?(Net::HTTPSuccess)
        token_data = JSON.parse(response.body)
        
        update(
          google_access_token: token_data["access_token"],
          google_token_expires_at: Time.now + token_data["expires_in"].to_i
        )
        
        return true
      else
        error_data = JSON.parse(response.body) rescue {}
        return false
      end
    rescue => e
      Rails.logger.error "Token refresh error: #{e.message}"
      return false
    end
  end

  def token_expired?
    return true unless google_token_expires_at
    google_token_expires_at < 5.minutes.from_now
  end

  def google_calendar_connected?
    google_access_token.present? && google_refresh_token.present?
  end

  def store_google_tokens(token_data)
    update(
      google_access_token: token_data["access_token"],
      google_refresh_token: token_data["refresh_token"],
      google_token_expires_at: Time.now + token_data["expires_in"].to_i
    )
  end

  def clear_google_tokens!
    update(
      google_access_token: nil,
      google_refresh_token: nil,
      google_token_expires_at: nil
    )
  end

  def can_access_calendar?
    return false unless google_calendar_connected?
    
    service = google_calendar_service
    service.present?
  end

  def send_welcome_email()
    Rails.logger.info "Sending welcome email to #{email}"
    UserMailer.welcome_email(self).deliver_later
  end


  private 

    def google_credentials
      google_access_token
    end
end
