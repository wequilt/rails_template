# frozen_string_literal: true

module Admin
  module Types
    class Mutation < Shared::Types::Base
      description 'The base mutation type for this schema'

      field :remove_me, String, 'Remove once other fields are added', inaccessible: true, shareable: true
    end
  end
end
