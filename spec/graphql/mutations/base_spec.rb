# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Base, type: :graphql do
  it 'defaults mutation payloads to null: false' do
    expect(described_class.null).to be(false)
  end
end
