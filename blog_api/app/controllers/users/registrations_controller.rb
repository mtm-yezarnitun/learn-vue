class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  
  protected

  def sign_up(resource_name, resource)
    true
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first
      render json: {
              message: 'Signed up successfully.',
              user: {
              name: resource.name,
              id: resource.id,
              email: resource.email,
              created_at: resource.created_at
            },
            token: token
      }, status: :created
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
    def sign_up_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def account_update_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
    end
end