class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :restrict_guest, only: [:edit, :update, :destroy, :show, :new]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def show
    #閲覧履歴の表示
    @user = current_user
    @read_histories = current_user.read_histories.includes(:book).order(created_at: :desc)

    #続きの書籍の表示
    @user = current_user
    @reading_books = current_user.ownerships.where(status: "reading").limit(5)
    @unread_books  = current_user.ownerships.where(status: "unread").limit(5)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "更新しました。"
    else
      flash.now[:alert] = "更新に失敗しました。"
      render :edit
    end
  end

  def destroy
    current_user.destroy
    reset_session
    redirect_to root_path, notice: "削除しました。"
  end

  private

  def user_params
    params.require(:user).permit(:user_name, :email, :password)
  end
end

