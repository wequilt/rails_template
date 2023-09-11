# frozen_string_literal: true

module Types
  class MutationPolicy < ApplicationPolicy
    allow_anonymous_access

    def authorized?(_object)
      true
    end
  end
end
