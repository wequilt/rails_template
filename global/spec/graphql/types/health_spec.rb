# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Health do
  subject(:data) { response_data.dig(:data, :health) }

  let(:allow_any_user?) { true }
  let(:allow_unauthenticated?) { true }
  let(:variables) { {} }
  let(:query) do
    %(
      query Health {
        health {
          #{selections}
        }
      }
    )
  end
  let(:selections) { 'deepCheck shallowCheck' }

  it 'returns true if all checks complete' do
    expect(data).to eq(deepCheck: true, shallowCheck: true)
  end
end
