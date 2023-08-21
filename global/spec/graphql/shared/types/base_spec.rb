# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::Types::Base, type: :graphql do
  subject(:type) { described_class }

  it_behaves_like 'a graphql base type'
end
