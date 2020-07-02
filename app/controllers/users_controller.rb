class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find_by(id: params[:id])
    unless params[:search].blank?
      @results = @user.query_profiles(params[:search])
    end
  end

  # GET /users/new
  def new
    @user = User.new
    @all_users = User.all
  end

  # GET /users/1/edit
  def edit
    @user = User.find_by(id: params[:id])
    # remove self from list of all users
    @all_users = User.all - [@user]
    @user_friends = @user.friendships.build
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    params[:friendship][:friend_id].each do |friend_id|
      if !friend_id.empty?
        @user.friendships.build(:friend_id => friend_id)
      end
    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    params[:friendship][:friend_id].each do |friend_id|
      if !friend_id.empty?
        @user.friendships.build(:friend_id => friend_id)
      end
    end
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.fetch(:user, {}).permit(:name, :personal_website, :search)
    end
end
