# frozen_string_literal: true

require_relative 'graphql_shared_context'

module GraphQLTypeContext
  extend RSpec::SharedContext
  include GraphQLSharedContext

  let(:record_id) { raise 'record_id must be implemented' }
  let(:allow_any_user?) { false }
  let(:use_entities?) do
    described_class.federation_directives.pluck(:name).any? { |name| %w[extends shareable].include?(name) }
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
      query GetNode($id: ID!) {
        node(id: $id) {
          ... on #{graphql_type} { #{selections} }
        }
      }
    )
  end
  let(:variables) do
    if use_entities?
      { representations: [{ __typename: graphql_type, id: record_id }] }
    else
      { id: record_id }
    end
  end

  context 'when selecting all fields' do
    let(:selections) do
      described_class.fields.map do |name, field|
        sub_field_for(field).then do |sub_field|
          if field.connection?
            "#{name} { nodes #{sub_field} }"
          else
            args_for(field).then do |args|
              args.present? ? "#{name}(#{args}) #{sub_field}" : "#{name} #{sub_field}"
            end
          end
        end
      end.join(' ')
    end

    it 'returns all of the fields without error' do
      expect(data.keys).to match_array(described_class.fields.symbolize_keys.keys)
    end
  end

  context 'when trying authenticated access with a random user' do
    let(:context) { { current_user: User.new(id: generate_user_gid) } }
    let(:have_expected_data) { allow_any_user? ? be_truthy : be_nil }
    let(:expected_error) { allow_any_user? ? nil : 'You are not authorized' }
    let(:expected_code) { allow_any_user? ? nil : 'AUTHORIZATION_FAILED' }

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
