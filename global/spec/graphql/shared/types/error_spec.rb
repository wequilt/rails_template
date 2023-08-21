# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::Types::Error, type: :graphql do
  subject(:type) { described_class.send(:new, error, current_user:) }

  let(:current_user) { User.new(id: '123') }
  let(:error) { ActiveModel::Error.new(:model, :screen_name, :blank) }

  describe '.authorized?' do
    subject(:authorized) { described_class.authorized?(nil, {}) }

    it 'returns true even when no user is logged in' do
      expect(authorized).to be(true)
    end
  end

  describe '#code' do
    subject(:code) { type.code }

    before do
      allow(Rails.logger).to receive(:error).with("Unhandled error type 'FOO', so returning 'INVALID'")
    end

    it 'returns the expected code' do
      expect(code).to eq('BLANK')
    end

    context 'when error is a Hash instead of ActiveModel::Error' do
      let(:error) { { type: :blank } }

      it 'returns the same result' do
        expect(code).to eq('BLANK')
      end
    end

    context 'when the error type is not defined in Enums::ErrorCode' do
      before do
        allow(error).to receive(:type).and_return('FOO')
        code
      end

      it 'returns INVALID for the code' do
        expect(code).to eq('INVALID')
      end

      it 'logs a warning-level message' do
        expect(Rails.logger).to have_received(:error).with("Unhandled error type 'FOO', so returning 'INVALID'")
      end
    end
  end

  describe '#field' do
    subject(:field) { type.field }

    it 'camelizes the field name' do
      expect(field).to eq('screenName')
    end

    context 'when error is a Hash instead of ActiveModel::Error' do
      let(:error) { { attribute: :screen_name } }

      it 'returns the same result' do
        expect(field).to eq('screenName')
      end
    end
  end
end
