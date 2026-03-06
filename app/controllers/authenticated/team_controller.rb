class Authenticated::TeamController < Authenticated::BaseController
  include Pagy::Method

  SORT_COLUMNS = {
    "name" => "users.last_name, users.first_name",
    "email" => "users.email",
    "role" => "account_users.role"
  }.freeze

  VALID_DIRECTIONS = %w[asc desc].freeze

  def index
    sort_col = SORT_COLUMNS.key?(params[:sort]) ? params[:sort] : "name"
    direction = VALID_DIRECTIONS.include?(params[:direction]) ? params[:direction] : "asc"

    members = Current.account.account_users
                     .includes(:user)
                     .order(Arel.sql("#{SORT_COLUMNS[sort_col]} #{direction}"))

    @pagy, @account_users = pagy(:offset, members, limit: 25)
    @pending_invitations = Current.account.invitations.pending if current_account_user&.can_manage_members?
  end
end
