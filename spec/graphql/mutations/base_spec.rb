# frozen_string_literal: true

require 'rails_helper'

class DummyPolicy < ApplicationPolicy
  def authorized?(user)
    user.id == 1
  end
end

RSpec.describe Mutations::Base, type: :graphql do
  subject(:mutation) { described_class.new(object:, context:, field:) }

  let(:context) { { current_user: user } }
  let(:field) { 'someField' }
  let(:object) { {} }
  let(:user) { User.find(1) }

  before do
    allow(Object).to receive(:const_get).with('Mutations::BasePolicy').and_return(DummyPolicy)
  end

  it 'defaults mutation payloads to null: false' do
    expect(described_class.null).to be(false)
  end

  describe '#authorized?' do
    let(:authorized) { mutation.authorized? }

    it 'returns true when the policy is authorized' do
      expect(authorized).to be(true)
    end

    context 'when policy is not authorized' do
      let(:user) { User.find(2) }

      it 'returns false' do
        expect(authorized).to be(false)
      end
    end
  end

  describe '#policy_class' do
    subject(:policy_class) { mutation.policy_class }

    it 'looks up the policy class using the class name of the mutation' do
      expect(policy_class).to eq(DummyPolicy)
    end
  end

  describe '#ready?' do
    let(:ready) { mutation.ready? }

    it 'returns true when a user is logged in' do
      expect(ready).to be(true)
    end

    context 'when no user is logged in' do
      let(:user) { nil }

      it 'raises AuthorizationFailed' do
        expect { ready }.to raise_error(AuthenticationFailed)
      end
    end

    context 'when context[:current_user] is not the correct type' do
      let(:user) { 500 }

      it 'raises ArgumentError' do
        expect { ready }.to raise_error(ArgumentError)
      end
    end
  end
end
