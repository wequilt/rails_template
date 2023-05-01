# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorizationFailed do
  let(:error) { described_class.new }

  it 'has a descriptive message' do
    expect(error.message).to eq('You are not authorized')
  end

  it 'has an error code' do
    expect(error.to_h).to include({ 'extensions' => { 'code' => 'AUTHORIZATION_FAILED' } })
  end
end
