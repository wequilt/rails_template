# frozen_string_literal: true

module UserHelpers
  def generate_user_gid
    Base64.urlsafe_encode64("gid://users/User/#{Faker::Number.number}", padding: false)
  end
end
