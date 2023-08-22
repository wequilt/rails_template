# frozen_string_literal: true

module Shared
  module Enums
    class Base < GraphQL::Schema::Enum
      description 'The base type for all enums'
    end
  end
end
