class Admin::PostsController < Admin::BaseController
  before_action :set_post, only: %i[show edit update destroy]

  def index
    @posts = Current.account.posts.order(created_at: :desc)
  end

  def show
  end

  def new
    @post = Current.account.posts.build(status: "draft")
  end

  def create
    @post = Current.account.posts.build(post_params)
    if @post.save
      redirect_to admin_post_path(@post), notice: "Post created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to admin_post_path(@post), notice: "Post updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to admin_posts_path, notice: "Post deleted."
  end

  private

  def set_post
    @post = Current.account.posts.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :slug, :body, :published_at, :status)
  end
end
