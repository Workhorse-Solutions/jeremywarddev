require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "verification_email is addressed to the user" do
    user = users(:alice)
    mail = UserMailer.verification_email(user)

    assert_equal [ user.email ], mail.to
    assert_equal "Please verify your email address", mail.subject
  end

  test "verification_email body contains a verify-email link with token" do
    user = users(:alice)
    mail = UserMailer.verification_email(user)

    assert_match "/verify-email", mail.body.encoded
    assert_match "token=", mail.body.encoded
  end
end
