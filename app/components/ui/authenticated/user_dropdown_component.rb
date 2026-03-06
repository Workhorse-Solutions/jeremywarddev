class UI::Authenticated::UserDropdownComponent < ViewComponent::Base
  def initialize(user_full_name:, user_email:, user_initials:, menu_items:, sign_out_label:, sign_out_href:)
    @user_full_name = user_full_name
    @user_email = user_email
    @user_initials = user_initials
    @menu_items = menu_items
    @sign_out_label = sign_out_label
    @sign_out_href = sign_out_href
  end

  private

  attr_reader :user_full_name, :user_email, :user_initials, :menu_items,
              :sign_out_label, :sign_out_href
end
