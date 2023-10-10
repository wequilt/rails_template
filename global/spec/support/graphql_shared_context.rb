# frozen_string_literal: true

require_relative 'graphql_context'

module GraphQLSharedContext
  extend RSpec::SharedContext
  include GraphQLContext

  let(:allow_unauthenticated?) { false }
  let(:auto_selections) do
    type_for_selection.fields.map do |name, field|
      sub_field_for(field).then do |sub_field|
        if field.connection?
          "#{name} { nodes #{sub_field} }"
        else
          args_for(field).then do |args|
            args.present? ? "#{name}(#{args}) #{sub_field}" : "#{name} #{sub_field}"
          end
        end
      end
    end.join(' ')
  end
  let(:selections) { auto_selections }
  let(:type_for_selection) { described_class }

  context 'when trying unauthenticated access' do
    let(:context) { {} }
    let(:errors) do
      # Treat Viewer as a special case where some fields may require authentication, so only look at top-level errors
      response_data.fetch(:errors, []).then do |errors|
        described_class.name == 'Types::Viewer' ? errors.filter { |e| e[:path].count == 1 } : errors
      end
    end
    let(:expected_error) { allow_unauthenticated? ? nil : failure_message }
    let(:expected_code) { allow_unauthenticated? ? nil : failure_code }
    let(:failure_message) { admin? ? /Schema is not configured for (queries|mutations)/ : 'Must be logged in' }
    let(:failure_code) { admin? ? /missing(Query|Mutation)Configuration/ : 'AUTHENTICATION_FAILED' }
    let(:have_expected_data) { allow_unauthenticated? ? be_truthy : be_nil }

    it 'conforms to allow_unauthenticated? for data' do
      expect(data).to have_expected_data
    end
    
    it 'conforms to allow_unauthenticated? for errors' do
      expect(errors.dig(0, :message)).to match(expected_error)
    end
    
    it 'conforms to allow_unauthenticated? for error code' do
      expect(errors.dig(0, :extensions, :code)).to match(expected_code)
    end
  end
end
