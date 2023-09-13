# frozen_string_literal: true

module Types
  class Viewer < Shared::Types::Base
    extend_type
    key fields: :id

    description 'The currently logged in user'

    field :id, ID, null: false, shareable: true

    def self.resolve_reference(_reference, context)
      context[:current_user].tap { |u| authorized?(u, context) } || ::User.new(id: Base64.encode64('unauthenticated'))
    end
  end
end
