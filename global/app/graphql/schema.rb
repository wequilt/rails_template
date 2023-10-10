# frozen_string_literal: true

class Schema < GraphQL::Schema
  include Shared::Schema

  description "The schema for the #{Rails.application.class.module_parent} application."

  include ApolloFederation::Schema
  federation version: '2.0'

  query Types::Query unless Types::Query.fields.empty?
  mutation Types::Mutation unless Types::Mutation.fields.empty?

  use GraphQL::Dataloader
  use GraphQL::Tracing::DataDogTracing, service: 'graphql'

  # Uncomment if needed
  # def self.mutation_authorized?(mutation, *, context:, **)
  #  policy_class_for(mutation).new(context[:current_user]).authorized?(*, **)
  # end

  def self.policy_class_for(type)
    Object.const_get("#{type}Policy")
  end

  # Uncomment if needed
  # def self.type_authorized?(type, object, context)
  #  policy_class_for(type).new(context[:current_user]).authorized?(object)
  # end

  def self.type_namespaces
    @type_namespaces ||= [Types, Shared::Types]
  end

  def self.type_visible?(_type, _context)
    true
  end
end
