# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fields::Base do
  subject(:field) { described_class.new(name: 'Dummy', type: String) }

  it 'includes Apollo Federation support' do
    expect(field.class).to include(ApolloFederation::Field)
  end

  it 'does not pull in any federation directives by default' do
    expect(field.directives).to be_empty
  end
end
