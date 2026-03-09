class Public::PagesController < Public::BaseController
  PROJECTS = YAML.load_file(Rails.root.join("config/projects.yml")).freeze

  def home
  end

  def pricing
  end

  def portfolio
    @projects = PROJECTS
  end

  def about
  end
end
