# frozen_string_literal: true

module Types
  class Mutation < Base
    description 'The mutation root of this schema'

    def self.authorized?(object, context)
      policy_class.new.authorized?(context[:current_user], object)
    end
  end
end
