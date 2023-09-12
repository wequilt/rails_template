# frozen_string_literal: true

module Types
  class Mutation < Shared::Types::Base
    description 'The mutation root of this schema'

    field :remove_me, String, 'Remove once other fields are added', inaccessible: true, shareable: true
  end
end
