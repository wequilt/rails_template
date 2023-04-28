# frozen_string_literal: true

class AuthorizationFailed < GraphQL::ExecutionError
  def initialize(*args, **kwargs)
    args[0] ||= 'You are not authorized'
    super(*args, **kwargs)
  end

  def to_h
    super.merge({ 'extensions' => { 'code' => 'AUTHORIZATION_FAILED' } })
  end
end
