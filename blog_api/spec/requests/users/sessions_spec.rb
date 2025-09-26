require 'rails_helper'

RSpec.describe "Login Sessions", type: :request do 
  let!(:user) { User.create!(email: "user@example.com", password: "password123") }

    #post
    describe "POST /login" do
      let(:valid_params) { { user: { email: user.email, password: "password123" } } }
      let(:invalid_params)  { { user: { email: user.email, password: "wrongpass" } } }
      

      it "login with valid credentials" do 
        post "/login", params: valid_params
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Logged in successfully.")
        expect(json["token"]).to be_present
        expect(json["user"]["email"]).to eq(user.email)
      end

      it "fails with invalid credentials" do
        post "/login", params: invalid_params
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to include("Invalid Email or password")
      end
    end

    #delete
    describe "DELETE /logout" do
        it "logs out the user" do
          post "/login", params: { user: { email: user.email, password: "password123" } }
          token = JSON.parse(response.body)["token"]
          delete "/logout", headers: { "Authorization" => "Bearer #{token}" }
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["message"]).to eq("Logged out successfully.")
        end
    end
end
