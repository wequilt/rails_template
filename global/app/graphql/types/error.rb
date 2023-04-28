# frozen_string_literal: true

module Types
  class Error < Base
    description 'An object describing an error for a specific field.'

    shareable

    field :field, String, null: false, method: :attribute
    field :message, String, null: false

    def self.authorized?(_object, _context)
      true
    end
  end
end
