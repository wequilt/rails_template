# frozen_string_literal: true

module Types
  class Mutation < Shared::Types::Base
    description 'The mutation root of this schema'

    def self.authorized?(object, context)
      MutationPolicy.new.authorized?(context[:current_user], object)
    end
  end
end
