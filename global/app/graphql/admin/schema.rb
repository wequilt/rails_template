# frozen_string_literal: true

module Admin
  class Schema < GraphQL::Schema
    include Shared::Schema

    description "The admin schema for the #{Rails.application.class.module_parent} graph"

    include ApolloFederation::Schema
    federation version: '2.0'

    query Admin::Types::Query unless Admin::Types::Query.fields.empty?
    mutation Admin::Types::Mutation unless Admin::Types::Mutation.fields.empty?

    use GraphQL::Dataloader
    use GraphQL::Tracing::DataDogTracing, service: 'graphql-admin'

    # Uncomment if needed
    # def self.mutation_authorized?(*, context:, **)
    #   context[:current_user].is_a?(AdminUser)
    # end

    # Uncomment if needed
    # def self.type_authorized?(_type, _object, context)
    #   context[:current_user].is_a?(AdminUser)
    # end

    def self.type_namespaces
      @type_namespaces ||= [Admin::Types, Shared::Types]
    end

    def self.type_visible?(_type, context)
      context[:current_user].is_a?(AdminUser)
    end
  end
end
