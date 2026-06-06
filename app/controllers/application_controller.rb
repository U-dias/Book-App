class ApplicationController < ActionController::Base
  helper_method :current_user
  before_action :require_login

  #ログインユーザー
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  #未ログインユーザー
  def require_login
    redirect_to new_session_path unless current_user
  end

  #ゲストユーザーの権限制限
  def restrict_guest
    return redirect_to root_path, alert: "ログイン後に利用できます。" if current_user&.guest?
  end
end
