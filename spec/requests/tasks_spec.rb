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

  # ============================================================
  # POST /tasks/:id/duplicate - タスク複製API
  # ============================================================
  describe 'POST /tasks/:id/duplicate' do
    let!(:original_task) do
      Task.create!(
        name: '元のタスク',
        explanation: 'タスクの説明文',
        genre: genre,
        priority: :high,
        status: 2,
        deadline_date: Date.new(2026, 6, 15)
      )
    end

    # ----------------------------------------------------------
    # 正常系 - 基本動作
    # ----------------------------------------------------------
    describe '正常系' do
      it 'A-1: 複製リクエストが成功し、HTTPステータス200または201が返ること' do
        post "/tasks/#{original_task.id}/duplicate"

        expect(response).to have_http_status(:success)
      end

      it 'A-2: レスポンスに複製されたタスクの情報が含まれること' do
        post "/tasks/#{original_task.id}/duplicate"

        json_response = JSON.parse(response.body)

        # レスポンス形式に応じて検証（配列形式の場合は複製タスクを検索）
        if json_response.is_a?(Array)
          duplicated_task_json = json_response.find { |t| t['name'] == '元のタスク(コピー)' }
          expect(duplicated_task_json).to be_present
        else
          expect(json_response['name']).to eq '元のタスク(コピー)'
        end
      end

      it 'A-3: DBのタスク件数が1件増加すること' do
        expect {
          post "/tasks/#{original_task.id}/duplicate"
        }.to change(Task, :count).by(1)
      end

      it '複製されたタスクがDBに正しく保存されていること' do
        post "/tasks/#{original_task.id}/duplicate"

        duplicated_task = Task.find_by(name: '元のタスク(コピー)')

        expect(duplicated_task).to be_present
        expect(duplicated_task.id).not_to eq original_task.id
      end
    end

    # ----------------------------------------------------------
    # 異常系 - リクエストエラー
    # ----------------------------------------------------------
    describe '異常系' do
      it 'A-10: 存在しないタスクIDを指定した場合、404エラーが返ること' do
        non_existent_id = 999999

        post "/tasks/#{non_existent_id}/duplicate"

        expect(response).to have_http_status(:not_found)
      end

      it 'A-11: 不正なID形式（文字列）を指定した場合、404エラーが返ること' do
        post '/tasks/invalid_id/duplicate'

        expect(response).to have_http_status(:not_found)
      end

      it 'A-12: IDにマイナス値を指定した場合、404エラーが返ること' do
        post '/tasks/-1/duplicate'

        expect(response).to have_http_status(:not_found)
      end

      it '存在しないタスクIDを指定した場合、DBのタスク件数が変わらないこと' do
        non_existent_id = 999999

        expect {
          post "/tasks/#{non_existent_id}/duplicate"
        }.not_to change(Task, :count)
      end
    end
  end
end
