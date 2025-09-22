require 'rails_helper'

RSpec.describe Post, type: :model do
  it { should belong_to(:user).optional }
  it { should have_many(:comments).dependent(:destroy) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }

  describe "#user_email" do
    it "returns the email of the user" do
      user = User.create!(email: "test@example.com", password: "password123")
      post = Post.create!(title: "Hello", body: "World", user: user)

      expect(post.user_email).to eq("test@example.com")
    end
  end
end
