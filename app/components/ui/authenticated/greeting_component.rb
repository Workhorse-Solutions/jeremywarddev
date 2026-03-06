class UI::Authenticated::GreetingComponent < ViewComponent::Base
  def initialize(greetings:, user_first_name: nil, account_name: nil)
    @greetings = greetings
    @user_first_name = user_first_name
    @account_name = account_name
  end

  private

  attr_reader :greetings, :user_first_name, :account_name

  def greeting_text
    hour = Time.current.hour
    if hour < 12
      greetings[:morning]
    elsif hour < 18
      greetings[:afternoon]
    else
      greetings[:evening]
    end
  end
end
