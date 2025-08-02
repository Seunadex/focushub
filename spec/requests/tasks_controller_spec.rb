require 'rails_helper'

RSpec.describe "TasksController", type: :request do
  let(:user) { create(:user) }
  let!(:task) { create(:task, user: user) }

  before { sign_in user }

  describe "GET /tasks" do
    it "returns a successful response" do
      get tasks_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /tasks/new" do
    it "renders the new task form" do
      get new_task_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /tasks" do
    context "with valid parameters" do
      it "creates a new task" do
        expect {
          post tasks_path, params: { task: { title: "Test", due_date: Date.tomorrow, priority: "low" } }
        }.to change(Task, :count).by(1)
      end
    end

    context "with invalid parameters" do
      it "does not create a new task" do
        expect {
          post tasks_path, params: { task: { title: "", due_date: "", priority: "low" } }
        }.not_to change(Task, :count)
      end
    end
  end

  describe "PATCH /tasks/:id" do
    it "updates the task" do
      patch task_path(task), params: { task: { title: "Updated Title" } }
      expect(task.reload.title).to eq("Updated Title")
    end
  end

  describe "DELETE /tasks/:id" do
    it "deletes the task" do
      expect {
        delete task_path(task)
      }.to change(Task, :count).by(-1)
    end
  end

  describe "PATCH /tasks/:id/complete" do
    it "marks task as complete" do
      patch complete_task_path(task), params: { completed: true }
      expect(response).to have_http_status(:redirect)
    end
  end
end
