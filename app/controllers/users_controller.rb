class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new create)
  before_action :load_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)

  def index
    @users = User.paginate(page: params[:page],
                           per_page: Settings.page.per_page)
  end

  def new
    @user = User.new
  end

  def show; end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "noti.send_active"
      redirect_to root_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = t "noti.update"
      redirect_to @user
    else
      flash.now[:danger] = t "noti.update_fail"
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "noti.delete"
    else
      flash[:danger] = t "noti.delete_fail"
    end
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user)
          .permit :name, :email, :password, :password_confirmation
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "noti.login"
    redirect_to login_path
  end

  def correct_user
    redirect_to root_url unless current_user?(@user)
  end

  def load_user
    @user = User.find_by(id: params[:id])
    return if @user

    flash[:danger] = t "noti.not_found"
    redirect_to signup_path
  end
end
