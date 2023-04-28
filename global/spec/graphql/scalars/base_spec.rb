# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scalars::Base do
  subject { described_class.new }

  it { is_expected.to be_a(GraphQL::Schema::Scalar) }
end
