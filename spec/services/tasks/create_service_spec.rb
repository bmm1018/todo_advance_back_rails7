require 'rails_helper'

RSpec.describe Tasks::CreateService, type: :service do
  let(:genre) { Genre.create!(name: 'テストジャンル') }

  describe '#call' do
    context '正常系' do
      it '有効なパラメータでTaskが作成されること' do
        params = {
          name: 'テストタスク',
          explanation: 'タスクの説明',
          genreId: genre.id,
          priority: 'high'
        }

        expect {
          Tasks::CreateService.new(params).call
        }.to change(Task, :count).by(1)
      end

      it '作成されたTaskを返すこと' do
        params = {
          name: 'テストタスク',
          explanation: 'タスクの説明',
          genreId: genre.id
        }

        result = Tasks::CreateService.new(params).call

        expect(result).to be_a(Task)
        expect(result).to be_persisted
        expect(result.name).to eq 'テストタスク'
      end
    end

    context 'パラメータ変換' do
      it 'genreId が genre_id に変換されること' do
        params = {
          name: 'テストタスク',
          genreId: genre.id
        }

        result = Tasks::CreateService.new(params).call

        expect(result.genre_id).to eq genre.id
      end

      it 'deadlineDate が deadline_date に変換されること' do
        deadline = Date.new(2026, 12, 31)
        params = {
          name: 'テストタスク',
          genreId: genre.id,
          deadlineDate: deadline
        }

        result = Tasks::CreateService.new(params).call

        expect(result.deadline_date).to eq deadline
      end
    end

    context 'デフォルト値' do
      it 'priority未指定時にデフォルト値（medium）が設定されること' do
        params = {
          name: 'テストタスク',
          genreId: genre.id
        }

        result = Tasks::CreateService.new(params).call

        expect(result.priority).to eq 'medium'
      end
    end
  end
end
