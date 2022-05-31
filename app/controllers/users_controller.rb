class UsersController < ApplicationController
  
  before_action :authenticate_user!
  
  def show
    if params[:id]
      @user = User.find(params[:id])
    else
      @user = current_user
    end
  end

  def friends
    @user = params[:user_id] ? User.find(params[:user_id]) : current_user
    @friends = @user.friends
  end

  def friend_requests
    @invitations = current_user.friend_invitations
  end

  def find_friends
  end

  private

  def profile_params
    params.require(:user)
          .permit(:name, :surname, :dateOfBirth, :gender, :email, :password, :password_confirmation)
  end
end