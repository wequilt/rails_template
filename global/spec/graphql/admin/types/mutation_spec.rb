# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Types::Mutation, type: :graphql do
  subject(:type) { described_class }

  it_behaves_like 'a graphql base type'
end
