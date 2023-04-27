# frozen_string_literal: true

module Interfaces
  module Base
    include GraphQL::Schema::Interface
    include ApolloFederation::Interface

    description 'Interface shared by all interface types.'

    field_class Fields::Base
  end
end
