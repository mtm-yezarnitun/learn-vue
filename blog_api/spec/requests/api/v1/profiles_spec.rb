require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let!(:user) { User.create!(email: "user@example.com", password: "password123", name: "Old Name") }

  before do
    allow_any_instance_of(Api::V1::ProfilesController).to receive(:current_user).and_return(user)
  end

  #get
  describe "GET /api/v1/profile" do
    it "returns the current user profile" do
      get "/api/v1/profile"
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
        email: "new_email@example.com",
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }
    end

    let(:invalid_params) do
        {
         user: {
            name: "",               
            email: "bad-email",     
            password: "short",   
            password_confirmation: "mismatch"
        }
        }
    end

    it "updates profile including password with valid data" do
        patch "/api/v1/profile", params: valid_params
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Updated successfully.")
        expect(json["user"]["name"]).to eq("New Name")
        expect(json["user"]["email"]).to eq("new_email@example.com")
        expect(user.reload.valid_password?("newpassword123")).to be true
    end

    it "returns errors with invalid data" do
        patch "/api/v1/profile", params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json).to have_key("email")
        expect(json).to have_key("password")
    end
  end

end