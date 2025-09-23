require 'rails_helper'

RSpec.describe "Users CRUD", type: :request do
  let!(:user) { User.create!(email: "user@example.com",password: "password123")}
  let!(:other_user) { User.create!(email: "secuser@example.com",password: "password123")}
  let(:token) do
    post "/login", params: { user: { email: user.email, password: "password123" } }
    JSON.parse(response.body)["token"]
  end
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

    #get
    describe "GET /admin/users" do
        it "list all users" do
            get "/admin/users" ,headers: headers
            expect(response).to have_http_status(:ok)
            json = JSON.parse(response.body)
            expect(json.first["email"]).to eq("secuser@example.com")
        end
    end

    #post
    describe "POST /admin/users" do 
        let(:post_params) { {user: {email: "tester@example.com", password:"12345678"} } } 
        let(:invalid_params) { {user: {email: "", password: "12345678"} } }

        it "creates a user in the database" do
            expect{ post "/admin/users", params: post_params ,headers: headers }.to change(User, :count).by(1)
            expect(response).to have_http_status(:created)
            json = JSON.parse(response.body)
            expect(json["message"]).to eq("User created")
        end

        it "cannot creates a user with invalid params" do
            expect{ post "/admin/users", params: invalid_params ,headers: headers }.not_to change(User, :count)
            expect(response).to have_http_status(:unprocessable_entity)
            json = JSON.parse(response.body)
            expect(json).to have_key("errors")
        end
    end

    #patch 
    describe "PATCH /admin/users/:id" do
        let(:update_params) { {user: { email: "newuser@example.com"} } }
        let(:invalid_params) { {user: { email: "bad-email"} } }

        it "updates a user with valid params" do
            patch "/admin/users/#{user.id}" , params: update_params ,headers: headers
            expect(response).to have_http_status(:ok)
            json= JSON.parse(response.body)
            expect(json["email"]).to eq("newuser@example.com")
        end

        it "cannot updates a user with invalid params" do
            patch "/admin/users/#{user.id}", params: invalid_params ,headers: headers
            expect(response).to have_http_status(:unprocessable_entity)
            json= JSON.parse(response.body)
            expect(json).to have_key("email")
        end
    end

    #put 
    describe "PUT /admin/users/:id" do
        let(:update_params) { {user: { email: "newuser@example.com" ,password:"11223344"} } }
        let(:invalid_params) { {user: { email: "" , password:"11223344"} } }

        it "updates a user with valid params" do
            put "/admin/users/#{user.id}", params: update_params ,headers: headers
            expect(response).to have_http_status(:ok)
            json= JSON.parse(response.body)
            expect(json["email"]).to eq("newuser@example.com")
            expect(user.reload.valid_password?("11223344")).to be true
        end

        it "cannot updates a user with invalid params" do
            put "/admin/users/#{user.id}", params: invalid_params ,headers: headers
            expect(response).to have_http_status(:unprocessable_entity)
            json= JSON.parse(response.body)
            expect(json).to have_key("email")
            expect(json["email"]).to include("can't be blank")
        end
    end

    #delete
    describe "DELETE /admin/users/:id" do
        it "deletes a user from the database" do
        expect {delete "/admin/users/#{user.id}" ,headers: headers }.to change(User, :count).by(-1)
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("User deleted successfully.")
        expect(User.count).to eq(1)
        end
    end
end