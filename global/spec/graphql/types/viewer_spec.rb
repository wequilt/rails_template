# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Viewer do
  let(:allow_any_user?) { true }
  let(:allow_unauthenticated?) { true }
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

    it 'returns the expected node ID of the current user' do
      expect(data).to eq(id: current_user.id)
    end
  end
end
