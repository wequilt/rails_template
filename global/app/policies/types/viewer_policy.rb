# frozen_string_literal: true

module Types
  class ViewerPolicy < ApplicationPolicy
    allow_anonymous_access

    def authorized?(_object)
      true
    end
  end
end
