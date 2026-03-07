class Public::SitemapsController < Public::BaseController
  def index
    @posts = BlogPost.all_published
    @projects = Project.all_projects

    respond_to do |format|
      format.xml { render layout: false }
    end
  end
end
