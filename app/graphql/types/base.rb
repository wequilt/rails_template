# frozen_string_literal: true

module Types
  class Base < GraphQL::Schema::Object
    include ApolloFederation::Object

    description 'Base class for all types in the schema'

    field_class Fields::Base

    # def self.authorized?(object, context)
    #   validate_authentication!(context)
    #   policy_class.new.authorized?(context[:current_user], object)
    # end

    # def self.policy_class
    #   Object.const_get("#{self}Policy")
    # end

    # def self.validate_authentication!(context)
    #   context[:current_user].tap do |user|
    #     raise AuthenticationFailed if user.blank?
    #     raise ArgumentError, "Wrong type for '#{user}'" unless user.is_a?(::User)
    #   end
    # end
  end
end
