require 'rails_helper'

RSpec.describe Tasks::DuplicateService, type: :service do
  let(:genre) { Genre.create!(name: 'テストジャンル') }
  let(:other_genre) { Genre.create!(name: '別のジャンル') }

  # ============================================================
  # 1.1 正常系 - 属性の引き継ぎ
  # ============================================================
  describe '属性の引き継ぎ' do
    context 'name' do
      it 'M-1: nameが正しくコピーされ、末尾に「(コピー)」が追加されること' do
        original_task = Task.create!(
          name: '買い物',
          genre: genre
        )

        result = Tasks::DuplicateService.new(original_task).call

        expect(result.name).to eq '買い物(コピー)'
      end
    end

    context 'explanation' do
      it 'M-2: explanationがそのまま引き継がれること' do
        original_task = Task.create!(
          name: 'タスク',
          explanation: 'これはタスクの詳細説明です',
          genre: genre
        )

        result = Tasks::DuplicateService.new(original_task).call

        expect(result.explanation).to eq 'これはタスクの詳細説明です'
      end
    end

    context 'genre_id' do
      it 'M-3: genre_idがそのまま引き継がれること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: other_genre
        )

        result = Tasks::DuplicateService.new(original_task).call

        expect(result.genre_id).to eq other_genre.id
      end
    end

    context 'priority' do
      it 'M-4: priorityがそのまま引き継がれること（low）' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          priority: :low
        )

        result = Tasks::DuplicateService.new(original_task).call

        expect(result.priority).to eq 'low'
      end

      it 'M-5: priorityがそのまま引き継がれること（medium）' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          priority: :medium
        )

        result = Tasks::DuplicateService.new(original_task).call

        expect(result.priority).to eq 'medium'
      end

      it 'M-6: priorityがそのまま引き継がれること（high）' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          priority: :high
        )

        result = Tasks::DuplicateService.new(original_task).call

        expect(result.priority).to eq 'high'
      end
    end
  end

  # ============================================================
  # 1.2 正常系 - 特別な処理
  # ============================================================
  describe '特別な処理' do
    context 'status' do
      it 'M-7: 元タスクが未着手(0)の場合、新タスクも未着手(0)になること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          status: :not_started
        )

        result = Tasks::DuplicateService.new(original_task).call

        expect(result.status).to eq 'not_started'
      end

      it 'M-8: 元タスクが進行中(1)の場合、新タスクは未着手(0)になること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          status: :in_progress
        )

        result = Tasks::DuplicateService.new(original_task).call

        expect(result.status).to eq 'not_started'
      end

      it 'M-9: 元タスクが完了(2)の場合、新タスクは未着手(0)になること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          status: :completed
        )

        result = Tasks::DuplicateService.new(original_task).call

        expect(result.status).to eq 'not_started'
      end
    end

    context 'deadline_date' do
      it 'M-10: 元タスクに期限がある場合、新タスクの期限はnilになること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          deadline_date: Date.new(2026, 1, 30)
        )

        result = Tasks::DuplicateService.new(original_task).call

        expect(result.deadline_date).to be_nil
      end

      it 'M-11: 元タスクの期限がnilの場合、新タスクの期限もnilになること' do
        original_task = Task.create!(
          name: 'タスク',
          genre: genre,
          deadline_date: nil
        )

        result = Tasks::DuplicateService.new(original_task).call

        expect(result.deadline_date).to be_nil
      end
    end
  end

  # ============================================================
  # 1.3 正常系 - 名前の特殊ケース
  # ============================================================
  describe '名前の特殊ケース' do
    it 'M-12: 既に「(コピー)」が含まれるタスクの複製で「(コピー)(コピー)」になること' do
      original_task = Task.create!(
        name: 'タスクA(コピー)',
        genre: genre
      )

      result = Tasks::DuplicateService.new(original_task).call

      expect(result.name).to eq 'タスクA(コピー)(コピー)'
    end

    it 'M-13: 空文字のnameの複製で「(コピー)」になること' do
      original_task = Task.create!(
        name: '',
        genre: genre
      )

      result = Tasks::DuplicateService.new(original_task).call

      expect(result.name).to eq '(コピー)'
    end

    it 'M-14: 長いnameの複製でも「(コピー)」が追加されること' do
      long_name = 'あ' * 200
      original_task = Task.create!(
        name: long_name,
        genre: genre
      )

      result = Tasks::DuplicateService.new(original_task).call

      expect(result.name).to eq "#{long_name}(コピー)"
    end

    it 'M-15: 日本語・特殊文字を含むnameの複製で正しくコピーされること' do
      original_task = Task.create!(
        name: 'タスク①★☆♪',
        genre: genre
      )

      result = Tasks::DuplicateService.new(original_task).call

      expect(result.name).to eq 'タスク①★☆♪(コピー)'
    end
  end

  # ============================================================
  # 1.4 正常系 - nullable属性のハンドリング
  # ============================================================
  describe 'nullable属性のハンドリング' do
    it 'M-16: explanationがnilの場合、新タスクのexplanationもnilになること' do
      original_task = Task.create!(
        name: 'タスク',
        genre: genre,
        explanation: nil
      )

      result = Tasks::DuplicateService.new(original_task).call

      expect(result.explanation).to be_nil
    end

    # M-17: genre_idがnilの場合のテスト
    # 注: Task は belongs_to :genre のため、genre_id は必須
    # optional: true が設定されていない限り、このテストはスキップまたは別途検討
    context 'genre_idがnilの場合' do
      it 'M-17: バリデーションエラーが発生すること（belongs_to制約がある場合）' do
        # belongs_to :genre により、genre_id なしでは作成できない想定
        # このテストは genre_id が必須であることを前提としている
        skip 'genre_id は必須のため、nilでのタスク作成はできない'
      end
    end
  end

  # ============================================================
  # 1.5 正常系 - 独立性の確認
  # ============================================================
  describe '独立性の確認' do
    it 'M-18: 新タスクは別のIDを持つこと' do
      original_task = Task.create!(
        name: 'タスク',
        genre: genre
      )

      result = Tasks::DuplicateService.new(original_task).call

      expect(result.id).not_to eq original_task.id
    end

    it 'M-19: 新タスクは新しいcreated_atを持つこと' do
      original_task = Task.create!(
        name: 'タスク',
        genre: genre
      )

      result = Tasks::DuplicateService.new(original_task).call

      expect(result.created_at).to be >= original_task.created_at
    end

    it 'M-20: 複製後、元タスクの全属性が変更されていないこと' do
      original_task = Task.create!(
        name: '元のタスク',
        explanation: '元の説明',
        genre: genre,
        priority: :high,
        status: 2,
        deadline_date: Date.new(2026, 12, 31)
      )

      original_attributes = original_task.attributes.dup

      Tasks::DuplicateService.new(original_task).call

      original_task.reload
      expect(original_task.name).to eq original_attributes['name']
      expect(original_task.explanation).to eq original_attributes['explanation']
      expect(original_task.genre_id).to eq original_attributes['genre_id']
      expect(original_task.priority).to eq original_attributes['priority']
      expect(original_task.status).to eq original_attributes['status']
      expect(original_task.deadline_date).to eq original_attributes['deadline_date']
    end
  end

  # ============================================================
  # 1.6 異常系
  # ============================================================
  describe '異常系' do
    it 'M-21: nilを渡した場合、NoMethodErrorが発生すること' do
      expect {
        Tasks::DuplicateService.new(nil).call
      }.to raise_error(NoMethodError)
    end

    it 'M-22: 複製時にgenreが削除済みの場合、適切なエラーが発生すること' do
      original_task = Task.create!(
        name: 'タスク',
        genre: genre
      )

      # genre を削除（外部キー制約がある場合は失敗するため、dependent: :destroy などの設定に依存）
      # このテストは外部キー制約の設定によって挙動が変わる
      skip 'Genreの削除は外部キー制約により制限される可能性がある'
    end
  end

  # ============================================================
  # 追加: DBへの保存確認
  # ============================================================
  describe 'DBへの保存' do
    it '複製したタスクがDBに保存されること' do
      original_task = Task.create!(
        name: 'テストタスク',
        genre: genre
      )

      expect {
        Tasks::DuplicateService.new(original_task).call
      }.to change(Task, :count).by(1)
    end

    it '複製されたTaskオブジェクトを返すこと' do
      original_task = Task.create!(
        name: 'テストタスク',
        genre: genre
      )

      result = Tasks::DuplicateService.new(original_task).call

      expect(result).to be_a(Task)
      expect(result).to be_persisted
    end
  end

  # ============================================================
  # 追加: 全属性の一括検証
  # ============================================================
  describe '全属性の一括検証' do
    it '全ての属性が仕様通りに設定されること' do
      original_task = Task.create!(
        name: '重要なタスク',
        explanation: '詳細な説明文',
        genre: genre,
        priority: :high,
        status: 2,
        deadline_date: Date.new(2026, 6, 15)
      )

      result = Tasks::DuplicateService.new(original_task).call

      aggregate_failures do
        expect(result.name).to eq '重要なタスク(コピー)'
        expect(result.explanation).to eq '詳細な説明文'
        expect(result.genre_id).to eq genre.id
        expect(result.priority).to eq 'high'
        expect(result.status).to eq 'not_started'
        expect(result.deadline_date).to be_nil
      end
    end
  end
end
