json.totalCount @total_count
json.countByStatus do
  json.notStarted @count_by_status[:not_started]
  json.inProgress @count_by_status[:in_progress]
  json.completed @count_by_status[:completed]
end
json.completionRate @completion_rate
