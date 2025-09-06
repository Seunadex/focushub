require 'rails_helper'

RSpec.describe UserDecorator do
  let(:user) { User.new(first_name: "John", last_name: "Doe", email: "john.doe@example.com") }
  let(:decorated_user) { user.decorate }

  describe "#full_name" do
    it "returns the user's full name" do
      expect(decorated_user.full_name).to eq("John Doe")
    end
  end

  describe "#abbreviated_name" do
    it "returns the user's email" do
      expect(decorated_user.abbreviated_name).to eq("JD")
    end
  end
end
