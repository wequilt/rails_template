# frozen_string_literal: true

class AuthenticationFailed < GraphQL::ExecutionError
  def initialize(*args, **kwargs)
    args[0] ||= 'Must be logged in'
    super(*args, **kwargs)
  end

  def to_h
    super.merge({ 'extensions' => { 'code' => 'AUTHENTICATION_FAILED' } })
  end
end
