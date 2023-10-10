# frozen_string_literal: true

module AuthenticationCheck
  def authorized?(*, **)
    raise AuthenticationFailed if require_authn? && user.blank?

    super.tap do |authorized|
      raise AuthorizationFailed unless authorized
    end
  end
end

class ApplicationPolicy
  attr_reader :user, :require_authn

  delegate :require_authn?, to: :class

  def self.inherited(subclass)
    subclass.prepend(AuthenticationCheck)
    super
  end

  def initialize(user)
    @user = user

    raise ArgumentError, "Wrong type for '#{user}'" unless user.blank? || user.is_a?(::User)
  end

  def authorized?(*, **)
    raise NotImplementedError
  end

  class << self
    attr_accessor :require_authn

    def allow_anonymous_access
      self.require_authn = false
    end

    def require_authn?
      require_authn.nil? ? true : require_authn
    end
  end
end
