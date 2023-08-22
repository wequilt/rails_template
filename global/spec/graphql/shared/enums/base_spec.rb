# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::Enums::Base do
  subject { described_class.new }

  it { is_expected.to be_a(GraphQL::Schema::Enum) }
end
