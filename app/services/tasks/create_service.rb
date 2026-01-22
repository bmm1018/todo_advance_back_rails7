module Tasks
  class CreateService
    def initialize(params)
      @params = params
    end

    def call
      Task.create(normalized_params)
    end

    private

    def normalized_params
      {
        name: @params[:name],
        explanation: @params[:explanation],
        status: @params[:status],
        priority: @params[:priority],
        genre_id: @params[:genreId],
        deadline_date: @params[:deadlineDate]
      }.compact
    end
  end
end
