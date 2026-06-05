class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create, :guest_login]

  def new
    @user = User.new
  end

  def create
    @user = User.find_by(email: params[:user][:email])
    if @user && @user.authenticate(params[:user][:password])
      session[:user_id] = @user.id
      redirect_to user_path(@user), notice: "ログインしました"
    else
      @user ||= User.new(email: params[:user][:email])

      @user.errors.add(:base, "メールアドレスまたはパスワードが違います")
      render :new, status: :unprocessable_entity
    end
    logger.debug "ERRORS: #{@user.errors.full_messages}"
  end

  def guest_login
    @user = User.find_or_create_by!(email: "guest@example.com") do |u|
      u.user_name = "ゲスト"
      u.password = "guestpassword"
    end
    session[:user_id] = @user.id
    redirect_to books_path
  end

  def destroy
    reset_session
    redirect_to new_session_path
  end
end
