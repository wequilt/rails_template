# frozen_string_literal: true

# FIXME: This is a temporary workaround for a bug in the apollo-federation-ruby gem.
# https://github.com/Gusto/apollo-federation-ruby/issues/207
module GraphQL
  module Types
    module Relay
      class PageInfo
        include ApolloFederation::Object
        include ApolloFederation::Field

        description 'Information about pagination in a connection.'

        shareable
      end
    end
  end
end

class Schema < GraphQL::Schema
  include ApolloFederation::Schema
  federation version: '2.0'

  description "The schema for the #{Rails.application.class.module_parent} application."

  query Types::Query unless Types::Query.fields.empty?
  mutation Types::Mutation unless Types::Mutation.fields.empty?

  use GraphQL::Dataloader
  use GraphQL::Tracing::DataDogTracing, service: 'graphql'

  def self.type_authorized?(type, object, context)
    validate_authentication!(context)
    policy_class_for(type).new.authorized?(context[:current_user], object)
  end

  def self.type_visible?(_type, _context)
    true
  end

  def self.resolve_type(_abstract_type, obj, _ctx)
    type_namespaces.find { |n| n.const_defined?(obj.class.name, false) }&.const_get(obj.class.name, false)
  end

  def self.id_from_object(object, _type_definition, _query_ctx)
    object.to_gid_param
  end

  def self.object_from_id(global_id, _query_ctx)
    GlobalID.find(global_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def self.unauthorized_object(_error)
    raise AuthorizationFailed
  end

  def self.policy_class_for(type)
    Object.const_get("#{type}Policy")
  end

  def self.validate_authentication!(context)
    context[:current_user].tap do |user|
      raise AuthenticationFailed if user.blank?
      raise ArgumentError, "Wrong type for '#{user}'" unless user.is_a?(::User)
    end
  end

  def self.type_namespaces
    @type_namespaces ||= [Types, Shared::Types]
  end
end
