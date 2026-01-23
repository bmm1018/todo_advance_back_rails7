module Tasks
  class DuplicateService
    COPY_SUFFIX = '(コピー)'
    DEFAULT_STATUS = :not_started
    DEFAULT_DEADLINE = nil

    def initialize(task)
      @task = task
    end

    def call
      Task.create!(duplicated_attributes)
    end

    private

    def duplicated_attributes
      {
        name: duplicated_name,
        explanation: @task.explanation,
        genre_id: @task.genre_id,
        priority: @task.priority,
        status: DEFAULT_STATUS,
        deadline_date: DEFAULT_DEADLINE
      }
    end

    def duplicated_name
      "#{@task.name}#{COPY_SUFFIX}"
    end
  end
end
