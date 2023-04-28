# frozen_string_literal: true

module Types
  class MutationPolicy < ApplicationPolicy
    def authorized?(_user, _object)
      true
    end
  end
end
