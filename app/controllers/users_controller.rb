class UsersController < ApplicationController
  def show
    @likes = current_user.likes
    @drumracks = current_user.drumracks
    @user = current_user
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
