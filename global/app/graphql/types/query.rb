# frozen_string_literal: true

module Types
  class Query < Shared::Types::Base
    description 'The base query type for this schema'

    field :health, Types::Health, 'Health of the server', inaccessible: true, resolver_method: :itself, shareable: true
    field :node,
          GraphQL::Types::Relay::Node,
          'Fetch a Node by its ID',
          null: true,
          inaccessible: true,
          shareable: true do
      argument :id, ID, 'The ID of the Node being requested', required: true
      argument :typename, String, 'The type name of the Node being requested', required: true
    end
    field :viewer, Types::Viewer, 'Currently logged in user', shareable: true

    def node(id:, typename:)
      context[:__typename] = typename
      Schema.object_from_id(id, context)
    end

    def viewer
      context[:current_user] || ::User.new(id: Base64.encode64('unauthenticated'))
    end

    def self.authorized?(object, context)
      QueryPolicy.new(context[:current_user]).authorized?(object)
    end
  end
end
