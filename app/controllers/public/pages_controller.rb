class Public::PagesController < Public::BaseController
  def home
    @recent_posts = BlogPost.recent(3)
    @projects = Project.featured
  end

  def pricing
  end

  def about
    set_meta_tags(
      title: "About",
      description: "Jeremy Ward — Solo Rails developer. 20 years shipping code. Building a portfolio of SaaS products."
    )
  end
end
