# frozen_string_literal: true

module Types
  class QueryPolicy < ApplicationPolicy
    def authorized?(_user, _object)
      true
    end
  end
end
