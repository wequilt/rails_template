# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUser do
  subject(:user) { described_class.new(email:) }

  let(:email) { 'foo@bar.com' }

  it 'has an email property that returns the initialized value' do
    expect(user.email).to eq(email)
  end

  it 'is equal to another user with the same email' do
    expect(user).to eq(described_class.new(email:))
  end

  describe '#id' do
    subject(:id) { user.id }

    it 'is an alias for email' do
      expect(id).to eq(email)
    end
  end

  describe '#graphql_id' do
    subject(:graphql_id) { user.graphql_id }

    it 'returns the expected value' do
      expect(graphql_id).to eq(user.to_gid_param)
    end
  end

  describe '.find' do
    subject(:find) { described_class.find(user.email) }

    it 'returns the expected user' do
      expect(find).to eq(user)
    end
  end
end
