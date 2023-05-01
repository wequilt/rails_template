# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Mutation, type: :graphql do
  subject(:type) { described_class }

  describe '.authorized?' do
    subject(:authorized) { type.authorized?(nil, {}) }

    it 'returns true even when no user is logged in' do
      expect(authorized).to be(true)
    end
  end
end
