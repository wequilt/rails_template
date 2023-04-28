# frozen_string_literal: true

module Types
  class ViewerPolicy < ApplicationPolicy
    def authorized?(user, object)
      user.id == object.id
    end
  end
end
