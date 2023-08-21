# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'a graphql schema' do
  let(:object) { AdminUser.new(email: Faker::Internet.email) }
  let(:id) { object.to_gid_param }

  describe '.object_from_id' do
    subject(:object_from_id) { schema.object_from_id(id, {}) }

    it 'returns the object' do
      expect(object_from_id).to eq(object)
    end

    context 'when the object is not found' do
      let(:id) { 'gid://app/AdminUser/0' }

      before { allow(AdminUser).to receive(:find).and_raise(ActiveRecord::RecordNotFound) }

      it 'returns nil' do
        expect(object_from_id).to be_nil
      end
    end
  end

  describe '.id_from_object' do
    subject(:id_from_object) { schema.id_from_object(object, {}, {}) }

    it 'returns the object ID' do
      expect(id_from_object).to eq(object.to_gid_param)
    end
  end

  describe '.resolve_type' do
    subject(:resolve_type) { schema.resolve_type({}, object, {}) }

    before do
      allow(Shared::Types).to receive(:const_defined?).with('AdminUser', false).and_return(true)
      allow(Shared::Types).to receive(:const_get).with('AdminUser', false).and_return(Shared::Types::Base)
    end

    it 'returns the type name' do
      expect(resolve_type).to eq([Shared::Types::Base, object])
    end
  end
end
