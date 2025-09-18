class Users::SessionsController < Devise::SessionsController
  respond_to :json

  def new
    render json: { error: '405 Method Not Allowed: Login must be submitted as a form. Please send a POST request.' }, status: :method_not_allowed
  end

  private
  def respond_with(resource, _opts = {})
    render json: {
      message: 'Logged in successfully.',
      user: resource,
      token: request.env['warden-jwt_auth.token']
    }, status: :ok
  end

  def respond_to_on_destroy
    if current_user
      render json: { message: 'Logged out successfully.' }, status: :ok
    else
      render json: { message: '401 Unauthorized: User has no active session.' }, status: :unauthorized
    end
  end
end
