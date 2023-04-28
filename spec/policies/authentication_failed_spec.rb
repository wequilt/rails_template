# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticationFailed do
  let(:error) { described_class.new }

  it 'has a descriptive message' do
    expect(error.message).to eq('Must be logged in')
  end

  it 'has an error code' do
    expect(error.to_h).to include({ 'extensions' => { 'code' => 'AUTHENTICATION_FAILED' } })
  end
end
