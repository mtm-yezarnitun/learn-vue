require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let!(:user) { User.create!(email: "user@example.com", password: "password123") }
  let!(:post_record) { Post.create!(title: "Hello", body: "World", user: user) }

  before do
    allow_any_instance_of(Api::V1::PostsController).to receive(:current_user).and_return(user)
  end

  #get all
  describe "GET /api/v1/posts" do
    it "lists all posts" do
      get "/api/v1/posts"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.first["title"]).to eq("Hello")
    end
  end

  #get one
  describe "GET /api/v1/posts/:id" do
    it "returns a single post" do
      get "/api/v1/posts/#{post_record.id}"   
      expect(response).to have_http_status(:ok)  
      json = JSON.parse(response.body)        
      expect(json["title"]).to eq("Hello")   
      expect(json["body"]).to eq("World")   
    end
  end

  #post 
  describe "POST /api/v1/posts" do
    let(:valid_params) { { post: { title: "New Post", body: "Content" } } }
    let(:invalid_params) { { post: { title: "", body: "    " } } }

    it "creates a post in the database" do
      expect{ post "/api/v1/posts", params: valid_params }.to change(Post, :count).by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Post created")
    end

    it "cannot creates a post with invalid params" do
      expect{ post "/api/v1/posts", params: invalid_params }.not_to change(Post, :count)
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json).to have_key("errors")
      expect(json["errors"]).to include("Title can't be blank")

    end
  end

  #patch
  describe "PATCH /api/v1/posts/:id" do
    let(:update_params) { { post: { title: "Updated" } } }
    let(:invalid_params) { { post: { title: "" } } }

    it "updates a post" do
      patch "/api/v1/posts/#{post_record.id}", params: update_params
      expect(response).to have_http_status(:ok)
      expect(post_record.reload.title).to eq("Updated")
    end

    it "cannot updates a post with invalid params" do
      patch "/api/v1/posts/#{post_record.id}", params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json).to have_key("errors")
      expect(json["errors"]).to include("Title can't be blank")
    end
  end

  #put
  describe "PUT /api/v1/posts/:id" do
    let(:put_params) { { post: { title: "Fully Updated", body: "New Body" } } }
    let(:invalid_put_params) { { post: { title: "", body: "" } } }

    it "fully updates a post" do
      put "/api/v1/posts/#{post_record.id}", params: put_params
      expect(response).to have_http_status(:ok)
      post_record.reload
      expect(post_record.title).to eq("Fully Updated")
      expect(post_record.body).to eq("New Body")
    end

    it "cannot fully update a post with invalid params" do
      put "/api/v1/posts/#{post_record.id}", params: invalid_put_params
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json).to have_key("errors")
      expect(json["errors"]).to include("Title can't be blank")
    end
  end


  #delete
  describe "DELETE /api/v1/posts/:id" do
    it "deletes a post from the database" do
      expect {delete "/api/v1/posts/#{post_record.id}"}.to change(Post, :count).by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Post deleted successfully.")
      expect(Post.count).to eq(0)
    end
  end
end
