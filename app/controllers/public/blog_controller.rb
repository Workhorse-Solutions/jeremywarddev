class Public::BlogController < Public::BaseController
  def index
    @posts = Post.published.recent
  end

  def show
    @post = Post.published.find_by!(slug: params[:slug])
  end

  def feed
    @posts = Post.published.recent.limit(20)
    respond_to do |format|
      format.rss { render layout: false }
    end
  end
end
