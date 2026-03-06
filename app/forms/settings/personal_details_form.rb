class Settings::PersonalDetailsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :first_name, :string
  attribute :last_name, :string

  attr_accessor :user

  def save
    return false unless valid?

    user.update(first_name: first_name, last_name: last_name)
  end
end
