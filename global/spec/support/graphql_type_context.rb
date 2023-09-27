# frozen_string_literal: true

require_relative 'graphql_shared_context'

module GraphQLTypeContext
  extend RSpec::SharedContext
  include GraphQLSharedContext

  let(:record_id) { raise 'record_id must be implemented' }
  let(:allow_any_user?) { admin? }
  let(:use_entities?) do
    described_class.federation_directives.pluck(:name).include?('key')
  end
  let(:graphql_type) { described_class.to_type_signature }
  let(:query) { use_entities? ? entities_query : node_query }
  let(:data) { use_entities? ? response_data.dig(:data, :_entities, 0) : response_data.dig(:data, :node) }
  let(:entities_query) do
    %(
        query GetEntities($representations: [_Any!]!) {
          _entities(representations: $representations) {
            ... on #{graphql_type} {
              #{selections}
            }
          }
        }
      )
  end
  let(:node_query) do
    %(
      query GetNode($id: ID!, $typename: String!) {
        node(id: $id, typename: $typename) {
          ... on #{graphql_type} { #{selections} }
        }
      }
    )
  end
  let(:variables) do
    if use_entities?
      { representations: [{ __typename: graphql_type, id: record_id }] }
    else
      { id: record_id, typename: graphql_type }
    end
  end

  context 'when selecting all fields' do
    let(:selections) { auto_selections }

    it 'returns all of the fields without error' do
      expect(data.keys).to match_array(described_class.fields.symbolize_keys.keys)
    end
  end

  context 'when trying authenticated access with a random user' do
    let(:context) { { current_user: random_user } }
    let(:have_expected_data) { allow_any_user? ? be_truthy : be_nil }
    let(:expected_error) { allow_any_user? ? nil : failure_message }
    let(:expected_code) { allow_any_user? ? nil : failure_code }
    let(:failure_message) { admin? ? /Schema is not configured for (queries|mutations)/ : 'You are not authorized' }
    let(:failure_code) { admin? ? /missing(Query|Mutation)Configuration/ : 'AUTHORIZATION_FAILED' }

    it 'conforms to allow_any_user? for data' do
      expect(data).to have_expected_data
    end

    it 'conforms to allow_any_user? for errors' do
      expect(response.dig('errors', 0, 'message')).to eq(expected_error)
    end

    it 'conforms to allow_any_user? for error code' do
      expect(response.dig('errors', 0, 'extensions', 'code')).to eq(expected_code)
    end
  end
end
