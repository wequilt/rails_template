# frozen_string_literal: true

module Shared
  module Types
    class Error < Base
      description 'An object describing an error for a specific field.'

      shareable

      field :field, String, null: false
      field :message, String, null: false

      # Null for: https://github.com/apollographql/apollo-ios/issues/2686
      field :code, Enums::ErrorCode, null: true

      def self.authorized?(_object, _context)
        true
      end

      def code
        (object.try(:type) || object[:type] || 'invalid').to_s.upcase.then do |code|
          return code if Enums::ErrorCode.values.keys.include?(code)

          Rails.logger.error("Unhandled error type '#{code}', so returning 'INVALID'")
          'INVALID'
        end
      end

      def field
        (object.try(:attribute) || object[:attribute]).to_s.camelize(:lower)
      end
    end
  end
end
