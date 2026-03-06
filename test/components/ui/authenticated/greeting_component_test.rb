require "test_helper"

class UI::Authenticated::GreetingComponentTest < ViewComponent::TestCase
  def default_greetings
    { morning: "Good Morning", afternoon: "Good Afternoon", evening: "Good Evening" }
  end

  def test_renders_time_appropriate_greeting
    render_inline(UI::Authenticated::GreetingComponent.new(greetings: default_greetings))
    hour = Time.current.hour
    expected = if hour < 12
      "Good Morning"
    elsif hour < 18
      "Good Afternoon"
    else
      "Good Evening"
    end
    assert_selector "p", text: /#{expected}/
  end

  def test_renders_user_first_name
    render_inline(UI::Authenticated::GreetingComponent.new(
      greetings: default_greetings,
      user_first_name: "Alice"
    ))
    assert_selector "span", text: ", Alice!"
  end

  def test_omits_name_when_not_provided
    result = render_inline(UI::Authenticated::GreetingComponent.new(greetings: default_greetings))
    assert_no_selector "span.max-sm\\:hidden"
  end

  def test_renders_account_name
    render_inline(UI::Authenticated::GreetingComponent.new(
      greetings: default_greetings,
      account_name: "Acme Corp"
    ))
    assert_selector "p", text: "Acme Corp"
  end

  def test_omits_account_name_when_not_provided
    result = render_inline(UI::Authenticated::GreetingComponent.new(greetings: default_greetings))
    assert_selector "p", count: 1
  end
end
