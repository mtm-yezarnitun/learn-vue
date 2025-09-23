require 'rails_helper'

RSpec.describe "User Registration", type: :request do
  
  #post
  describe "POST /signup" do
    let(:valid_params) do  {
        user: {
          name: "Tester",
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123",
        }
      }
    end

    let(:invalid_params) do {
        user: {
          name: "",
          email: "bad-email",
          password: "short",
          password_confirmation: "adadasq",
        }
      }
    end

    it "registers a new user with valid params" do
      expect {
        post "/signup", params: valid_params
      }.to change(User, :count).by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Signed up successfully.")
      expect(json["user"]["email"]).to eq("test@example.com")
      expect(json["token"]).to be_present
    end

    it "does not register with invalid params" do
      expect {
        post "/signup", params: invalid_params
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)

      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end
  end
end
