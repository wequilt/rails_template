# frozen_string_literal: true

module Shared
  module Enums
    class ErrorCode < Base
      description 'The associated code for an Error type'

      value 'BLANK', 'Cannot be blank'
      value 'EXCLUSION', 'Must be excluded'
      value 'INCLUSION', 'Must be included'
      value 'INVALID', 'Catchall for other invalid scenarios'
      value 'NOT_A_NUMBER', 'Must be a number'
      value 'NOT_AN_INTEGER', 'Must be an integer'
      value 'PRESENT', 'Cannot be present'
      value 'TAKEN', 'Value is already taken'
    end
  end
end
