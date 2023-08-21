# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::Enums::ErrorCode do
  subject(:enum) { described_class }

  it 'has the correct set of values' do
    expect(enum.values.keys).to eq(
      %w[
        BLANK
        EXCLUSION
        INCLUSION
        INVALID
        NOT_A_NUMBER
        NOT_AN_INTEGER
        PRESENT
        TAKEN
      ],
    )
  end
end
