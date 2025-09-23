require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let!(:user) { User.create!(email: "user@example.com", password: "password123", name: "Old Name") }
  let(:token) do
    post "/login", params: { user: { email: user.email, password: "password123" } }
    JSON.parse(response.body)["token"]
  end
  let(:headers) { { "Authorization" => "Bearer #{token}" } }
  
  #get
  describe "GET /api/v1/profile" do
    it "returns the current user profile" do
      get "/api/v1/profile" ,headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["email"]).to eq("user@example.com")
      expect(json["name"]).to eq("Old Name")
    end
  end

 # patch
  describe "PATCH /api/v1/profile" do
    let(:valid_params) do
    {
      user: {
        name: "New Name",
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }
    end

    let(:invalid_params) do
        {
         user: {
            name: "",               
            password: "short",   
            password_confirmation: "mismatch"
        }
        }
    end

    it "updates profile including password with valid data" do
        patch "/api/v1/profile", params: valid_params ,headers: headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Updated successfully.")
        expect(json["user"]["name"]).to eq("New Name")
        expect(user.reload.valid_password?("newpassword123")).to be true
    end

    it "returns errors with invalid data" do
        patch "/api/v1/profile", params: invalid_params ,headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json).to have_key("password")
    end
  end
  # put
  describe "PUT /api/v1/profile" do
    let(:full_update_params) do
      {
        user: {
          name: "Fully Updated Name",
          email: "fully_updated@example.com",
          password: "securepassword456",
          password_confirmation: "securepassword456"
        }
      }
    end

    let(:invalid_full_update_params) do
      {
        user: {
          name: "",               
          email: "invalid-email",     
          password: "123",   
          password_confirmation: "456"
        }
      }
    end

    it "fully updates the profile with valid data" do
      put "/api/v1/profile", params: full_update_params ,headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Updated successfully.")
      expect(json["user"]["name"]).to eq("Fully Updated Name")
      expect(json["user"]["email"]).to eq("fully_updated@example.com")
      expect(user.reload.valid_password?("securepassword456")).to be true
    end

    it "returns errors when full update data is invalid" do
      put "/api/v1/profile", params: invalid_full_update_params ,headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json).to have_key("email")
      expect(json).to have_key("password")
    end
  end

end