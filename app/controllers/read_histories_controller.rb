class ReadHistoriesController < ApplicationController
  def index
    @read_histories = current_user.read_histories.includes(:book).order(created_at: :desc).limit(5)
  end

  def show
  end
end
