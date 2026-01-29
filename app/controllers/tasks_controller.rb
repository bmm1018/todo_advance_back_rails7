class TasksController < ApplicationController
  before_action :select_task, only: [:update, :destroy, :update_status]
  skip_before_action :verify_authenticity_token

  def index
    tasks_all
  end

  def create
    @result = Task.create(task_params)
    tasks_all
  end

  def update
    @task.update(task_params)
    tasks_all
  end

  def destroy
    @task.destroy
    tasks_all
  end

  def update_status
    @task.update(status: params[:status])
    tasks_all
  end

  def report
    stats = Task.statistics
    @total_count = stats[:total_count]
    @count_by_status = stats[:count_by_status]
    @completion_rate = stats[:completion_rate]

    render :report
  end

  private

  def task_params
    params.permit(:name, :explanation, :status).merge(genre_id: params[:genreId], deadline_date: params[:deadlineDate])
  end

  def select_task
    @task = Task.find(params[:id])
  end

  def tasks_all
    @tasks = Task.all
    render :all_tasks
  end
end
