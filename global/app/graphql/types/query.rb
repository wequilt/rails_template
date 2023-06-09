# frozen_string_literal: true

module Types
  class Query < Base
    description 'The base query type for this schema'

    field :viewer, Types::Viewer, 'Currently logged in user', shareable: true

    def viewer
      raise AuthenticationFailed if context[:current_user].blank?

      context[:current_user]
    end

    def self.authorized?(object, context)
      QueryPolicy.new.authorized?(context[:current_user], object)
    end
  end
end
