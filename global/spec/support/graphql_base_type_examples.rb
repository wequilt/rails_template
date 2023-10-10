# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'a federated base type' do
  it 'includes Apollo Federation support' do
    expect(type).to include(ApolloFederation::Object)
  end

  it 'does not pull in any federation directives by default' do
    expect(type.directives).to be_empty
  end
end

RSpec.shared_examples 'a graphql base type' do
  it 'configures the custom Field::Base as its field type' do
    expect(type.field_class).to eq(Fields::Base)
  end
end

RSpec.shared_examples 'a graphql base mutation' do
  it 'configures the custom GraphQL::Schema::Field as its field type' do
    expect(type.field_class).to eq(GraphQL::Schema::Field)
  end
end

shared_examples 'prevent non-admin access' do
  let(:current_user) { nil }

  it 'returns false when no user is logged in' do
    expect(method).to be(false)
  end

  context 'when logged in but not an admin' do
    let(:current_user) { User.new(id: SecureRandom.uuid) }

    it 'returns false' do
      expect(method).to be(false)
    end
  end

  context 'when an admin is logged in' do
    let(:current_user) { AdminUser.new(email: Faker::Internet.email) }

    it 'returns true' do
      expect(method).to be(true)
    end
  end
end
