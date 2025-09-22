require 'rails_helper'

RSpec.describe Comment, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:post) }

  it { should validate_presence_of(:content) }

  describe "creating a comment" do
    it "is valid with user, post, and content" do
      user = User.create!(email: "test@example.com", password: "password123")
      post = Post.create!(title: "Hello", body: "World", user: user)
      comment = Comment.new(content: "Nice post!", user: user, post: post)

      expect(comment).to be_valid
    end
  end
end
