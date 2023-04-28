# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interfaces::Base do
  subject(:interface) { described_class }

  it 'includes Apollo Federation support' do
    expect(interface).to include(ApolloFederation::Interface)
  end

  it 'does not pull in any federation directives by default' do
    expect(interface.directives).to be_empty
  end

  it 'configures the custom Field::Base as its field type' do
    expect(interface.field_class).to eq(Fields::Base)
  end
end
