class Admin::BaseController < Authenticated::BaseController
  layout "admin"

  before_action :require_system_admin!

  private

  def require_system_admin!
    head :not_found unless Current.user&.system_admin?
  end
end
