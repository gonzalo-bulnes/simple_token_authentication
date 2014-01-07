class PrivatePostsController < ApplicationController

  # Please do notice that this controller DOES call `acts_as_authentication_handler`.
  # See test/dummy/spec/requests/posts_specs.rb
  acts_as_token_authentication_handler

  before_action :set_private_post, only: [:show, :edit, :update, :destroy]

  # GET /private_posts
  def index
    @private_posts = PrivatePost.all
  end

  # GET /private_posts/1
  def show
  end

  # GET /private_posts/new
  def new
    @private_post = PrivatePost.new
  end

  # GET /private_posts/1/edit
  def edit
  end

  # POST /private_posts
  def create
    @private_post = PrivatePost.new(private_post_params)

    if @private_post.save
      redirect_to @private_post, notice: 'Private post was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /private_posts/1
  def update
    if @private_post.update(private_post_params)
      redirect_to @private_post, notice: 'Private post was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /private_posts/1
  def destroy
    @private_post.destroy
    redirect_to private_posts_url, notice: 'Private post was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_private_post
      @private_post = PrivatePost.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def private_post_params
      params.require(:private_post).permit(:title, :body, :published)
    end
end
