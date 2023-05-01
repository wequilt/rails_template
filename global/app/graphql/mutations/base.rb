# frozen_string_literal: true

module Mutations
  class Base < GraphQL::Schema::RelayClassicMutation
    description 'Base class for all mutations in the schema'

    null false

    def authorized?(*args, **kwargs)
      policy_class.new.authorized?(context[:current_user], *args, **kwargs)
    end

    def policy_class
      Object.const_get("#{self.class}Policy")
    end

    def ready?(*_args, **_kwargs)
      context[:current_user].tap do |user|
        raise AuthenticationFailed if user.blank?
        raise ArgumentError, "Wrong type for '#{user}'" unless user.is_a?(::User)
      end.present?
    end
  end
end
