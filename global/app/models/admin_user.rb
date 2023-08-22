# frozen_string_literal: true

class AdminUser
  include GlobalID::Identification

  attr_reader :email

  def initialize(email:)
    @email = email
  end

  alias id email

  def graphql_id
    to_gid_param
  end

  def ==(other)
    email == other.email
  end

  def self.find(email)
    new(email:)
  end
end
