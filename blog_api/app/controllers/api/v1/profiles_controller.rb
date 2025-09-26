module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authenticate_user!

      # GET /api/v1/profile
      def show
        render json: current_user
      end

      # PATCH/PUT /api/v1/profile
      def update
        if current_user.update(profile_params)
          render  json:{
              "user": current_user,
              "message": "Updated successfully."
            } ,status: :ok
        else
          render json: current_user.errors, status: :unprocessable_entity
        end
      end

      private

      # Only allow the user to update their own email/password
      def profile_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
