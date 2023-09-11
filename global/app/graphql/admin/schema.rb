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

module Admin
  class Schema < GraphQL::Schema
    include ApolloFederation::Schema
    federation version: '2.0'

    description "The admin schema for the #{Rails.application.class.module_parent} graph"

    query Admin::Types::Query unless Admin::Types::Query.fields.empty?
    mutation Admin::Types::Mutation unless Admin::Types::Mutation.fields.empty?

    use GraphQL::Dataloader
    use GraphQL::Tracing::DataDogTracing, service: 'graphql-admin'

    def self.type_authorized?(_type, _object, context)
      context[:current_user].is_a?(AdminUser)
    end

    def self.type_visible?(_type, context)
      context[:current_user].is_a?(AdminUser)
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

    def self.type_namespaces
      @type_namespaces ||= [Admin::Types, Shared::Types]
    end
  end
end
