class Public::ProjectsController < Public::BaseController
  def index
    @projects = Project.all_projects
    set_meta_tags(
      title: "Projects",
      description: "SaaS products and tools built by Jeremy Ward. Real software in production, not side projects."
    )
  end
end
