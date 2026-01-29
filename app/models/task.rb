class Task < ApplicationRecord
  belongs_to :genre

  enum status: {
    not_started: 0,
    in_progress: 1,
    completed: 2
  }

  def self.statistics
    counts = group(:status).count
    total = counts.values.sum

    {
      total_count: total,
      count_by_status: {
        not_started: counts[statuses[:not_started]] || 0,
        in_progress: counts[statuses[:in_progress]] || 0,
        completed: counts[statuses[:completed]] || 0
      },
      completion_rate: calculate_completion_rate(total, counts[statuses[:completed]] || 0)
    }
  end

  def self.calculate_completion_rate(total, completed)
    return 0.0 if total.zero?
    ((completed.to_f / total) * 100).round(1)
  end
end
