# frozen_string_literal: true

module Admin
  module Types
    class Query < Shared::Types::Base
      description 'The base query type for this schema'

      field :viewer, Admin::Types::Viewer, 'Currently logged in admin user', shareable: true

      def viewer
        context[:current_user].tap do |user|
          raise AuthenticationFailed unless user
        end
      end

      def self.authorized?(_object, context)
        context[:current_user].present?
      end
    end
  end
end
