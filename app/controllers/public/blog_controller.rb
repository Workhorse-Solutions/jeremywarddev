class Public::BlogController < Public::BaseController
  before_action :set_current_account

  def index
    @posts = Current.account.posts.published.recent
  end

  def show
    @post = Current.account.posts.published.find_by!(slug: params[:slug])
  end

  def feed
    @posts = Current.account.posts.published.recent.limit(20)
    respond_to do |format|
      format.rss { render layout: false }
    end
  end

  private

  # Single-tenant: resolve the default account for public-facing pages.
  # In a multi-tenant app, this would resolve via subdomain or custom domain.
  def set_current_account
    Current.account ||= Account.first!
  end
end
