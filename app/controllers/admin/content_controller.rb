class Admin::ContentController < Admin::BaseController
  before_action :set_content, only: [:show, :edit, :update, :approve, :reject, :destroy]

  def index
    @pending = Current.account.agent_contents.pending_approval.recent
    @approved = Current.account.agent_contents.approved.recent.limit(10)
    @scheduled = Current.account.agent_contents.scheduled.order(:scheduled_for)
  end

  def show
  end

  def edit
  end

  def update
    if @content.update(content_params)
      redirect_to admin_content_path(@content), notice: "Content updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def approve
    @content.update!(
      status: :approved,
      approved_at: Time.current
    )

    # If blog post, create Post record
    if @content.blog_post?
      Post.create!(
        account: Current.account,
        title: @content.title,
        body: @content.body,
        status: "published",
        published_at: @content.scheduled_for || Time.current
      )
      @content.update!(
        status: :published,
        published_at: Time.current
      )
    end

    redirect_to admin_content_index_path, notice: "Content approved and published."
  end

  def reject
    @content.update!(
      status: :rejected,
      metadata: (@content.metadata || {}).merge("rejection_note" => params[:note])
    )
    redirect_to admin_content_index_path, notice: "Content rejected."
  end

  def destroy
    @content.destroy
    redirect_to admin_content_index_path, notice: "Content deleted."
  end

  private

  def set_content
    @content = Current.account.agent_contents.find(params[:id])
  end

  def content_params
    params.require(:agent_content).permit(:title, :body, :scheduled_for)
  end
end
