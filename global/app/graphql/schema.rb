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

  description "The schema for the #{Rails.application.class.module_parent.to_s} application."

  query Types::Query
  mutation Types::Mutation

  use GraphQL::Dataloader
  use GraphQL::Tracing::DataDogTracing, service: 'graphql'

  def self.resolve_type(_abstract_type, obj, _ctx)
    Object.const_get("Types::#{obj.class.name}")
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
end
