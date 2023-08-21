# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Schema do
  let(:id) { object.to_gid_param }
  let(:object) { create(:episode) }
  let(:types) { described_class.types.values.map(&:name).compact }

  it 'only contains types in the Admin, Shared, GraphQL, and ApolloFederation namespaces' do
    expect(types).to all(match(/\A(Admin|Shared|GraphQL|ApolloFederation)::/))
  end

  describe '.object_from_id' do
    subject(:object_from_id) { described_class.object_from_id(id, {}) }

    it 'returns the object' do
      expect(object_from_id).to eq(object)
    end

    context 'when the object is not found' do
      let(:id) { "gid://app/#{object.class.name}/0" }

      it 'returns nil' do
        expect(object_from_id).to be_nil
      end
    end
  end

  describe '.id_from_object' do
    subject(:id_from_object) { described_class.id_from_object(object, {}, {}) }

    it 'returns the object ID' do
      expect(id_from_object).to eq(object.to_gid_param)
    end
  end

  describe '.resolve_type' do
    subject(:resolve_type) { described_class.resolve_type({}, object, {}) }

    it 'returns the type name' do
      expect(resolve_type).to eq([Admin::Types::Episode, object])
    end
  end
end
