require 'rails_helper'

RSpec.describe 'Tasks API', type: :request do
  let(:genre) { Genre.create!(name: 'テストジャンル') }

  describe 'POST /tasks' do
    context 'priorityパラメータを指定した場合' do
      it 'priority: highを指定してタスクを作成できること' do
        task_params = {
          name: 'テストタスク',
          explanation: 'タスクの説明',
          genreId: genre.id,
          priority: 'high'
        }

        expect {
          post '/tasks', params: task_params
        }.to change(Task, :count).by(1)

        created_task = Task.last
        expect(created_task.priority).to eq 'high'
      end

      it 'priority: lowを指定してタスクを作成できること' do
        task_params = {
          name: 'テストタスク',
          explanation: 'タスクの説明',
          genreId: genre.id,
          priority: 'low'
        }

        post '/tasks', params: task_params

        created_task = Task.last
        expect(created_task.priority).to eq 'low'
      end
    end

    context 'priorityパラメータを指定しない場合' do
      it 'デフォルト値（medium）でタスクが作成されること' do
        task_params = {
          name: 'テストタスク',
          explanation: 'タスクの説明',
          genreId: genre.id
        }

        post '/tasks', params: task_params

        created_task = Task.last
        expect(created_task.priority).to eq 'medium'
      end
    end

    context 'レスポンスJSON' do
      it '作成されたタスクのpriorityがレスポンスJSONに含まれていること' do
        task_params = {
          name: 'テストタスク',
          explanation: 'タスクの説明',
          genreId: genre.id,
          priority: 'high'
        }

        post '/tasks', params: task_params

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        # レスポンスは配列形式（全タスク一覧）
        created_task_json = json_response.find { |t| t['name'] == 'テストタスク' }
        expect(created_task_json).to be_present
        expect(created_task_json['priority']).to eq 'high'
      end
    end
  end
end
