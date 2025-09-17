class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :register, :register_user]

  def new
    redirect_to root_path if user_signed_in?
  end

  def create
    user = User.find_by(username: params[:username])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Successfully logged in!"
    else
      flash.now[:alert] = "Invalid username or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Successfully logged out!"
  end

  def register
    redirect_to root_path if user_signed_in?
    @user = User.new
  end

  def register_user
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Account created successfully!"
    else
      render :register, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end
end