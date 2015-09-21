class PostsController < ApplicationController
  before_filter :require_user_signed_in
  before_action :set_post, only: [:show, :edit, :update, :destroy, :vote, :delete_from_twitter, :publish_to_twitter]

  # GET /posts
  # GET /posts.json
  def index
    # @posts = Post.where(["linked_account_id in (?) AND (post_at > ? or post_at is null)", current_user.linked_accounts.pluck(:id), DateTime.now]).order("post_at asc")
    # @posts = Post.where(["linked_account_id in (?)", current_user.linked_accounts.pluck(:id)])
    @posts = Post.all
  end

  def index_all
    @posts = Post.where(["linked_account_id in (?)", current_user.linked_accounts.pluck(:id)])
    render :index
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    linked_account_ids = post_params.delete(:linked_account_ids)
    linked_accounts = current_user.linked_accounts.where(id: linked_account_ids)
    save_successful = create_multiple_from_linked_accounts(linked_accounts)

    # @post = Post.new(post_params)

    respond_to do |format|
      if save_successful
        format.html { redirect_to posts_path, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to posts_path, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def publish_to_twitter
    respond_to do |format|
      if @post.post_to_twitter
        format.html { redirect_to posts_path, notice: 'Post was successfully published to your Twitter feed.' }
        format.json { render :index, status: :created, location: @post }
      else
        format.html { redirect_to posts_path, notice: "Cannot Post: #{@post.errors.full_messages.join("<br />")}".html_safe }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete_from_twitter
    respond_to do |format|
      if @post.delete_from_twitter
        format.html { redirect_to posts_path, notice: 'Post was deleted from your Twitter feed.' }
        format.json { render :index, status: :created, location: @post }
      else
        format.html { redirect_to posts_path, notice: "Cannot Un-Publish: #{@post.errors.full_messages.join("<br />")}".html_safe }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  private #####################################################################

    def create_multiple_from_linked_accounts(linked_accounts)
      return (@post = Post.new(post_params) and @post.save) unless linked_accounts.present?
      begin
        ActiveRecord::Base.transaction do
          linked_accounts.each do |linked_account|
            save_successful = false
            @post = Post.new(post_params)
            @post.linked_account = linked_account
            @post.save!
            save_successful = true
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        @post.linked_account_ids = linked_accounts.map(&:id)
        save_successful = false
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      hsh = params.require(:post).permit(:text, :type, :post_at, :linked_account_id, :linked_account_ids => [])
      hsh[:post_at] = Chronic.parse(hsh[:post_at]) if hsh[:post_at].present?
      hsh
    end
end
