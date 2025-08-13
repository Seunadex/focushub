require 'rails_helper'

RSpec.describe "HabitsController", type: :request do
  let(:user) { create(:user) }
  let!(:habit) { create(:habit, user: user) }

  before { sign_in(user, scope: :user) }

  describe "GET /habits" do
    it "returns a successful response" do
      get habits_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /habits/new" do
    it "renders the new habit form" do
      get new_habit_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /habits" do
    context "with valid parameters" do
      it "creates a new habit" do
        expect {
          post habits_path, params: { habit: { title: "Exercise", description: "Stay fit", frequency: "daily", target: 1 } }
        }.to change(Habit, :count).by(1)
        expect(response).to have_http_status(:redirect)
      end
    end

    context "with invalid parameters" do
      it "does not create a new habit" do
        expect {
          post habits_path, params: { habit: { title: "", frequency: "", target: "" } }
        }.not_to change(Habit, :count)
      end
    end
  end

  describe "GET /habits/:id/edit" do
    it "renders the edit form" do
      get edit_habit_path(habit)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /habits/:id" do
    it "updates the habit" do
      patch habit_path(habit), params: { habit: { title: "Updated Title" } }
      expect(habit.reload.title).to eq("Updated Title")
    end
  end

  describe "DELETE /habits/:id" do
    it "deletes the habit" do
      expect {
        delete habit_path(habit)
      }.to change(Habit, :count).by(-1)
    end
  end
end
