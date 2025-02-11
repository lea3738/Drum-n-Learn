class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_user, only: [:show]

  def show
    @current_user = current_user
    @user_liked_drumracks = @user.liked_drumracks
    @user_drumracks = @user.drumracks
  end

  def index
    @users = User.all
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username,
                                 :email,
                                 :password,
                                 :password_confirmation,
                                 :profile_picture,
                                 :soundcloud_link,
                                 :bio)
  end
end
