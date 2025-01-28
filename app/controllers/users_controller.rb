class UsersController < ApplicationController
skip_before_action :authenticate_user!, only: [:index, :show]
before_action :set_user, only: [:show]

  def show
    @likes = @user.likes
    @current_user = current_user
    @drumracks = @user.drumracks
  end

  def index
    @users = User.all
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :profile_picture, :soundcloud_link, :bio)
  end
end
