module Fields
  class Base < GraphQL::Schema::Field
    include ApolloFederation::Field
  end
end
