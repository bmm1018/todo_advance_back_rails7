require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @genre = Genre.create!(name: "Test Genre")
  end

  test "should get report with correct statistics" do
    # テストデータ作成
    Task.create!(name: "Task 1", status: :not_started, genre: @genre)
    Task.create!(name: "Task 2", status: :in_progress, genre: @genre)
    Task.create!(name: "Task 3", status: :completed, genre: @genre)
    Task.create!(name: "Task 4", status: :completed, genre: @genre)

    get report_tasks_url, as: :json

    assert_response :success
    json = JSON.parse(response.body)

    assert_equal 4, json["totalCount"]
    assert_equal 1, json["countByStatus"]["notStarted"]
    assert_equal 1, json["countByStatus"]["inProgress"]
    assert_equal 2, json["countByStatus"]["completed"]
    assert_equal 50.0, json["completionRate"]
  end

  test "should return 0 completion rate when no tasks exist" do
    Task.destroy_all

    get report_tasks_url, as: :json

    assert_response :success
    json = JSON.parse(response.body)

    assert_equal 0, json["totalCount"]
    assert_equal 0.0, json["completionRate"]
  end

  test "should handle 100 percent completion rate" do
    Task.create!(name: "Task 1", status: :completed, genre: @genre)
    Task.create!(name: "Task 2", status: :completed, genre: @genre)

    get report_tasks_url, as: :json

    assert_response :success
    json = JSON.parse(response.body)

    assert_equal 2, json["totalCount"]
    assert_equal 2, json["countByStatus"]["completed"]
    assert_equal 100.0, json["completionRate"]
  end
end
