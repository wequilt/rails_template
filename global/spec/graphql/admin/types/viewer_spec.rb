# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Types::Viewer, type: :graphql do
  subject(:data) { response_data.dig(:data, :viewer) }

  let(:allow_any_user?) { true }
  let(:current_user) { AdminUser.new(email: Faker::Internet.email) }
  let(:query) do
    %(
      query Viewer {
        viewer {
          #{selections}
        }
      }
    )
  end
  let(:selections) { 'id email' }

  it 'returns the expected data' do
    expect(data).to eq(id: current_user.to_gid_param, email: current_user.email)
  end

  context 'when the user is not logged in' do
    subject(:error) { response_data.dig(:errors, 0, :extensions) }

    let(:current_user) { nil }

    it 'returns no data' do
      expect(data).to be_nil
    end

    it 'returns a low level GraphQL error indicating the schema is empty' do
      expect(error).to eq(code: 'missingQueryConfiguration')
    end
  end
end
