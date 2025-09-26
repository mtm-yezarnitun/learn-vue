class Api::V1::GoogleAuthController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'

  def login
    Rails.logger.info "Params received: #{params.inspect}"

    id_token = params[:id_token]
    return render json: { error: 'Missing id_token' }, status: :bad_request unless id_token

    payload = verify_google_id_token(id_token)
    Rails.logger.info "Google payload: #{payload.inspect}"
    return render json: { error: 'Invalid ID token' }, status: :unauthorized unless payload

    user = User.where(provider: 'google_oauth2', uid: payload['sub']).first_or_initialize
    user.email = payload['email']
    user.password ||= Devise.friendly_token[0, 20]
    user.provider = 'google_oauth2'
    user.uid = payload['sub']
    user.save!

    token, _ = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)

    render json: {
      message: 'Logged in successfully.',
      user: { id: user.id, email: user.email },
      token: token
    }
  rescue => e
    Rails.logger.error "Google login error: #{e.message}"
    render json: { error: 'Internal server error' }, status: :internal_server_error
  end

  private

  def verify_google_id_token(id_token)
    uri = URI.parse("https://oauth2.googleapis.com/tokeninfo?id_token=#{id_token}")
    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  rescue => e
    Rails.logger.error "Google ID token verification failed: #{e.message}"
    nil
  end
end
