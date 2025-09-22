require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:posts).dependent(:destroy) }
  it { should have_many(:comments).dependent(:destroy) }

  it { should define_enum_for(:role).with_values(user: 0, admin: 1) }

  it "is valid with valid email and password" do
    user = User.new(email: "test@example.com", password: "password123")
    expect(user).to be_valid
  end
end