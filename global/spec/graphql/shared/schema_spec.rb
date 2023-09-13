# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schema do
  let(:schema) { described_class }

  it_behaves_like 'a graphql schema'
end
