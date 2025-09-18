class Admin::UsersController < ApplicationController
  before_action :require_admin!
  before_action :set_user, only: [ :update, :destroy ]

  def index
    @users = User.order(:username)
  end

  def update
    # Prevent admin from removing their own admin role
    if @user == current_user && @user.role == "admin" && user_params[:role] == "user"
      redirect_to admin_users_path, alert: t("flash.admin_role_protection")
      return
    end

    if @user.update(user_params)
      redirect_to admin_users_path, notice: t("flash.user_updated")
    else
      redirect_to admin_users_path, alert: t("common.error")
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: t("users.cannot_delete_self")
    else
      @user.destroy
      redirect_to admin_users_path, notice: t("flash.user_deleted")
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    role = params[:user]&.[](:role)

    # Explicitly validate role to address security concerns
    unless role.nil? || %w[admin user].include?(role)
      raise ActionController::BadRequest, "Invalid role specified"
    end

    # Only permit role if it's a valid value
    if role && %w[admin user].include?(role)
      { role: role }
    else
      {}
    end
  end
end
