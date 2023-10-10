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

module Shared
  module Schema
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def resolve_type(_abstract_type, obj, ctx)
        return ctx.warden.get_type(ctx[:__typename]) if ctx[:__typename].present?

        type_namespaces.find { |n| n.const_defined?(obj.class.name, false) }&.const_get(obj.class.name, false)
      end

      def id_from_object(object, _type_definition, _query_ctx)
        object.to_gid_param
      end

      # Determine whether the global_id is for an ActiveRecord model that is sourced from this service. If so,
      # load the object decoding the GID into its Rails ID. If not a Rails model, simply use the GID as the object's ID.
      def object_from_id(global_id, _query_ctx)
        GlobalID.parse(global_id).then do |parts|
          parts.app.eql?('messaging') ? GlobalID.find(global_id) : parts.model_class.find(global_id)
        end
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end
  end
end
