# frozen_string_literal: true

require_relative 'graphql_context'

module GraphQLSharedContext
  extend RSpec::SharedContext
  include GraphQLContext

  let(:allow_unauthenticated?) { false }

  context 'when trying unauthenticated access' do
    let(:context) { {} }
    let(:have_expected_data) { allow_unauthenticated? ? be_truthy : be_nil }
    let(:expected_error) { allow_unauthenticated? ? nil : 'Must be logged in' }
    let(:expected_code) { allow_unauthenticated? ? nil : 'AUTHENTICATION_FAILED' }

    it 'conforms to allow_unauthenticated? for data' do
      expect(data).to have_expected_data
    end

    it 'conforms to allow_unauthenticated? for errors' do
      expect(response.dig('errors', 0, 'message')).to eq(expected_error)
    end

    it 'conforms to allow_unauthenticated? for error code' do
      expect(response.dig('errors', 0, 'extensions', 'code')).to eq(expected_code)
    end
  end
end
