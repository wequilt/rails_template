# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  subject(:user) { described_class.new(data) }

  let(:data) { { id:, name: } }
  let(:id) { SecureRandom.uuid }
  let(:name) { Faker::Name.name }

  shared_examples 'return expected values' do
    it { is_expected.to have_attributes(id:) }
  end

  it_behaves_like 'return expected values'

  it 'can find an object from id' do
    expect(described_class.find(id).id).to eq(id)
  end

  context 'when object with same data is instantiated' do
    let(:same_data_user) { described_class.new(data) }

    it 'equals the another object' do
      expect(user).to eq(same_data_user)
    end
  end

  context 'when data is a string-keyed hash' do
    let(:data) { { 'id' => id } }

    it_behaves_like 'return expected values'
  end
end
