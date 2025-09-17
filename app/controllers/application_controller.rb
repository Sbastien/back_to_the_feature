class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  helper_method :current_user, :user_signed_in?, :admin_user?

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    current_user.present?
  end

  def admin_user?
    current_user&.admin?
  end

  def authenticate_user!
    redirect_to login_path unless user_signed_in?
  end

  def require_admin!
    redirect_to root_path unless admin_user?
  end
end
