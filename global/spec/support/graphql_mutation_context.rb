# frozen_string_literal: true

require_relative 'graphql_shared_context'

module GraphQLMutationContext
  extend RSpec::SharedContext
  include GraphQLSharedContext

  let(:allow_any_user?) { false }
  let(:return_type) { described_class.name.demodulize.sub(/^./, &:downcase) }
  let(:allowed_nullable_fields) { [] }

  context 'when inspecting the mutation definition' do
    described_class.fields.excluding('errors').each do |name, field|
      it "returns expected nullability for '#{name}'" do
        expect(field.type.non_null?).to be(allowed_nullable_fields.include?(field.method_sym))
      end
    end

    it 'is non-nullable for errors' do
      expect(described_class.get_field('errors').type.non_null?).to be(true)
    end
  end

  context 'when trying authenticated access with a random user' do
    let(:context) { { current_user: User.new(id: generate_user_gid) } }
    let(:have_expected_data) { allow_any_user? ? be_truthy : be_nil }
    let(:has_any_error) do
      [
        response.dig('errors', 0, 'message').present?,
        response.dig('data', return_type, 'errors').present?
      ].any?
    end

    it 'conforms to allow_any_user? for data' do
      expect(data).to have_expected_data
    end

    it 'conforms to allow_any_user? for errors' do
      expect(has_any_error).not_to eq(allow_any_user?)
    end
  end
end
