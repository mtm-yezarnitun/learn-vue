require 'rails_helper'

RSpec.describe "API::V1::Comments", type: :request do
  let!(:user) { User.create!(email: "user@example.com", password: "password123") }
  let!(:other_user) { User.create!(email: "other@example.com", password: "password123") }
  let!(:post_record) { Post.create!(title: "Hello", body: "World", user: user) }
  let!(:comment) { Comment.create!(content: "First comment", post: post_record, user: user) }

  before do
    allow_any_instance_of(Api::V1::CommentsController).to receive(:current_user).and_return(user)
  end

  #get all
  describe "GET /api/v1/posts/:post_id/comments" do
    it "lists all comments for a post" do
      get "/api/v1/posts/#{post_record.id}/comments"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.first["content"]).to eq("First comment")
      expect(json.first["user"]["email"]).to eq("user@example.com")
    end
  end

  #post 
  describe "POST /api/v1/posts/:post_id/comments" do
    let(:valid_params) { { comment: { content: "New comment" } } }
    let(:invalid_params) { { comment: { content: "" } } }

    it "creates a comment under the post" do
      expect { post "/api/v1/posts/#{post_record.id}/comments", params: valid_params }.to change(Comment, :count).by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["content"]).to eq("New comment")
      expect(json["user"]["email"]).to eq("user@example.com")
    end
    
    it "cannot creates a comment with invalid params" do
      expect { post "/api/v1/posts/#{post_record.id}/comments", params: invalid_params }.not_to change(Comment, :count)
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json).to have_key("errors")
      expect(json["errors"]).to include("Content can't be blank")
    end
  end

  #delete
  describe "DELETE /api/v1/posts/:post_id/comments/:id" do
    it "deletes a comment if owner" do
      expect {delete "/api/v1/posts/#{post_record.id}/comments/#{comment.id}"}.to change(Comment, :count).by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Comment deleted successfully.")
    end
  end
end
