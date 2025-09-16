require 'rails_helper'

RSpec.describe "HabitCompletionsController", type: :request do
  let(:user) { create(:user) }
  let!(:habit) { create(:habit, user: user) }

  before { sign_in(user, scope: :user) }

  describe "DELETE /habits/:habit_id/habit_completions/undo" do
    it "undoes the last completion and redirects with notice" do
      habit.complete!(Date.current)
      expect(habit.habit_completions.count).to eq(1)

      delete undo_habit_habit_completions_path(habit)
      expect(response).to have_http_status(:redirect)
      expect(flash[:notice]).to match(/undone/i)
      expect(habit.reload.habit_completions.count).to eq(0)
    end
  end
end
