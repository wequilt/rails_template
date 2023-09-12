# frozen_string_literal: true

module Shared
  module Mutations
    class Base < GraphQL::Schema::RelayClassicMutation
      description 'Base class for all mutations in the schema'

      null false

      # Uncomment if needed
      # def authorized?(*, **)
      #   context.schema.mutation_authorized?(self.class, *, **, context:)
      # end
      #
      # def self.visible?(context)
      #   context.schema.type_visible?(self, context)
      # end
    end
  end
end
