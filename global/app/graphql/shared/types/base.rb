# frozen_string_literal: true

module Shared
  module Types
    class Base < GraphQL::Schema::Object
      include ApolloFederation::Object

      description 'Base class for all types in the schema'

      field_class Fields::Base

      # Uncomment if needed
      # def self.authorized?(object, context)
      #   context.schema.type_authorized?(self, object, context)
      # end
      #
      # def self.visible?(context)
      #   context.schema.type_visible?(self, context)
      # end
    end
  end
end
