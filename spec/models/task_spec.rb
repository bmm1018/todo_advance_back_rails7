require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:genre) { Genre.create!(name: 'テストジャンル') }

  describe 'priority' do
    context 'enum定義' do
      it '優先度が「低(low)」「中(medium)」「高(high)」のいずれかであること' do
        expect(Task.priorities).to eq({ 'low' => 0, 'medium' => 1, 'high' => 2 })
      end

      it '低(low)を設定できること' do
        task = Task.new(name: 'テストタスク', genre: genre, priority: :low)
        expect(task.priority).to eq 'low'
        expect(task.low?).to be true
      end

      it '中(medium)を設定できること' do
        task = Task.new(name: 'テストタスク', genre: genre, priority: :medium)
        expect(task.priority).to eq 'medium'
        expect(task.medium?).to be true
      end

      it '高(high)を設定できること' do
        task = Task.new(name: 'テストタスク', genre: genre, priority: :high)
        expect(task.priority).to eq 'high'
        expect(task.high?).to be true
      end
    end

    context 'デフォルト値' do
      it '新規タスク作成時に、優先度のデフォルト値が「中(medium)」であること' do
        task = Task.create!(name: 'テストタスク', genre: genre)
        expect(task.priority).to eq 'medium'
      end
    end
  end
end
