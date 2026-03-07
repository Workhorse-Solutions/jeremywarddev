class Public::BlogController < Public::BaseController
  def index
    @posts = BlogPost.all_published
    set_meta_tags(
      title: "Blog",
      description: "Build-in-public updates, Rails insights, and lessons from 20 years shipping code."
    )
  end

  def show
    @post = BlogPost.find_by_slug!(params[:slug])
    set_meta_tags(
      title: @post.title,
      description: @post.excerpt,
      og: {
        title: @post.title,
        description: @post.excerpt,
        type: "article",
        url: blog_post_url(@post.slug)
      }
    )
  end

  def feed
    @posts = BlogPost.all_published
    respond_to do |format|
      format.rss { render layout: false }
    end
  end
end
