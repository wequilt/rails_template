# frozen_string_literal: true

module GraphQLContext
  extend RSpec::SharedContext

  let(:admin?) { described_class.to_s.split('::').first == 'Admin' }
  let(:current_user) { User.new(id: generate_user_gid) }
  let(:context) { { current_user: } }
  let(:data) { field_data[model_name] }
  let(:field_data) { response_data[:data].first.last }
  let(:input) { {} }
  let(:model_name) { described_class.to_s.split('::').last.underscore.split('_').first.to_sym }
  let(:model) { model_name.to_s.capitalize.constantize }
  let(:record) { nil }
  let(:response) { schema.execute(query, variables:, context:, operation_name: nil) }
  let(:response_data) { response.to_h.deep_symbolize_keys }
  let(:schema) { admin? ? Admin::Schema : Schema }
  let(:variables) { { id: record&.graphql_id, input: } }
end
