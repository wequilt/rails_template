# frozen_string_literal: true

class ApplicationPolicy
  def authorized?(*args, **kwargs)
    raise NotImplementedError
  end
end
