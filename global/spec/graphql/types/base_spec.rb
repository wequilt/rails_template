# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Base, type: :graphql do
  subject(:type) { described_class }

  it 'includes Apollo Federation support' do
    expect(type).to include(ApolloFederation::Object)
  end

  it 'does not pull in any federation directives by default' do
    expect(type.directives).to be_empty
  end

  it 'configures the custom Field::Base as its field type' do
    expect(type.field_class).to eq(Fields::Base)
  end
end
