# frozen_string_literal: true

require 'rails_helper'

class Dummy
  include GlobalID::Identification

  attr_reader :id

  def initialize(id)
    @id = id.to_i
  end

  def ==(other)
    id == other.id
  end

  def self.find(id)
    new(id) if id.to_i > 0
  end
end

RSpec.describe Schema do
  let(:schema) { described_class }

  let(:object) { Dummy.new(1) }
  let(:id) { object.to_gid_param }

  describe '.object_from_id' do
    subject(:object_from_id) { schema.object_from_id(id, {}) }

    it 'returns the object' do
      expect(object_from_id).to eq(object)
    end

    context 'when the GID is invalid' do
      let(:id) { 'gid://app/Dummy/0' }

      it 'returns nil' do
        expect(object_from_id).to be_nil
      end
    end

    context 'when the GID is valid but the object does not exist' do
      before { allow(GlobalID).to receive(:find).with(id).and_raise(ActiveRecord::RecordNotFound) }

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
    subject(:resolve_type) { described_class.resolve_type({}, object, {}) }

    before do
      allow(Object).to receive(:const_get).with('Types::Dummy').and_return(Types::Base)
    end

    it 'returns the type name' do
      expect(resolve_type).to eq([Types::Base, object])
    end
  end

  describe '.unauthorized_object' do
    subject(:unauthorized_object) { described_class.unauthorized_object('message') }

    it 'raises an error' do
      expect { unauthorized_object }.to raise_error(AuthorizationFailed)
    end
  end
end
