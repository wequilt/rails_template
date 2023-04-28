# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Viewer do
  let(:allow_any_user?) { true }
  let(:record_id) { current_user&.id }
  let(:selections) { 'id' }
  let(:user_id) { current_user.id }

  context 'when accessing via Viewer' do
    subject(:data) { response_data.dig(:data, :viewer) }

    let(:query) do
      %(
      query Viewer {
        viewer {
          #{selections}
        }
      }
    )
    end

    context 'without authentication' do
      let(:current_user) { nil }

      it 'does not return data' do
        expect(data).to be_nil
      end

      it 'returns an authentication error' do
        expect(response.dig('errors', 0, 'message')).to eq('Must be logged in')
      end

      it 'returns an error code' do
        expect(response.dig('errors', 0, 'extensions', 'code')).to eq('AUTHENTICATION_FAILED')
      end
    end
  end
end
