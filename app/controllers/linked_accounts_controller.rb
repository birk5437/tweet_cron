# require 'twitter_oauth'

class LinkedAccountsController < ApplicationController
  before_filter :require_user_signed_in
  before_action :set_linked_account, only: [:show, :edit, :update, :destroy]

  # GET /linked_accounts
  # GET /linked_accounts.json
  def index
    @linked_accounts = current_user.linked_accounts
  end

  # GET /linked_accounts/1
  # GET /linked_accounts/1.json
  def show
  end

  # GET /linked_accounts/new
  def new
    @linked_account = LinkedAccount.new
  end

  # GET /linked_accounts/1/edit
  def edit
  end

  # POST /linked_accounts
  # POST /linked_accounts.json
  def create
    @linked_account = LinkedAccount.new(linked_account_params)

    respond_to do |format|
      if @linked_account.save
        format.html { redirect_to linked_accounts_path, notice: 'LinkedAccount was successfully created.' }
        format.json { render :index, status: :created, location: @linked_account }
      else
        format.html { render :new }
        format.json { render json: @linked_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /linked_accounts/1
  # PATCH/PUT /linked_accounts/1.json
  def update
    respond_to do |format|
      if @linked_account.update(linked_account_params)
        format.html { redirect_to linked_accounts_path, notice: 'LinkedAccount was successfully updated.' }
        format.json { render :show, status: :ok, location: @linked_account }
      else
        format.html { render :edit }
        format.json { render json: @linked_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /linked_accounts/1
  # DELETE /linked_accounts/1.json
  def destroy
    @linked_account.destroy
    respond_to do |format|
      format.html { redirect_to linked_accounts_url, notice: 'LinkedAccount was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def twitter_callback
    client = TwitterOAuth::Client.new(
        :consumer_key => SECRET_CONFIG[Rails.env]["twitter"]["consumer_key"],
        :consumer_secret => SECRET_CONFIG[Rails.env]["twitter"]["consumer_secret"],
    )
    # request_token_token = session[:request_token_token]
    # request_token_secret = 
    access_token = client.authorize(
      session[:request_token_token],
      session[:request_token_secret],
      :oauth_verifier => params[:oauth_verifier]
    )

    @linked_account = current_user.linked_accounts.find_or_initialize_by(remote_identifier: access_token.params[:user_id], type: "TwitterAccount")

    @linked_account.auth_data = access_token.params
    @linked_account.updated_at = DateTime.now
    @linked_account.save!

    respond_to do |format|
      format.html { redirect_to linked_accounts_url, notice: 'Account successfully authorized!' }
      format.json { render :show, status: :ok, location: @linked_account }
    end


  end

  def twitter_auth
    client = TwitterOAuth::Client.new(
        :consumer_key => SECRET_CONFIG[Rails.env]["twitter"]["consumer_key"],
        :consumer_secret => SECRET_CONFIG[Rails.env]["twitter"]["consumer_secret"],
    )
    request_token = client.request_token(:oauth_callback => twitter_callback_linked_accounts_url)
    session[:request_token_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    redirect_to request_token.authorize_url + "&force_login=true"

  end

  def omniauth_callback
    @linked_account = current_user.linked_accounts.find_or_initialize_by(remote_identifier: omniauth_auth_hash[:uid], type: "FacebookAccount")
    @linked_account.auth_data = omniauth_auth_hash
    @linked_account.updated_at = DateTime.now
    @linked_account.save!

    respond_to do |format|
      format.html { redirect_to linked_accounts_url, notice: 'Account successfully authorized!' }
      format.json { render :show, status: :ok, location: @linked_account }
    end
  end

  protected ###################################################################

  def omniauth_auth_hash
    request.env['omniauth.auth']
  end

  private #####################################################################
    # Use callbacks to share common setup or constraints between actions.
    def set_linked_account
      @linked_account = LinkedAccount.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def linked_account_params
      hsh = params.require(:linked_account).permit(:text, :type, :linked_account_at)
      hsh[:linked_account_at] = Chronic.parse(hsh[:linked_account_at]) if hsh[:linked_account_at].present?
      hsh
    end
end
