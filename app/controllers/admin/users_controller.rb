class Admin::UsersController < ApplicationController
  before_action :require_admin!
  before_action :set_user, only: [:update, :destroy]

  def index
    @users = User.order(:username)
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User was successfully updated."
    else
      redirect_to admin_users_path, alert: "Failed to update user."
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: "Cannot delete yourself."
    else
      @user.destroy
      redirect_to admin_users_path, notice: "User was successfully deleted."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:role)
  end
end