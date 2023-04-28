# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationRecord do
  it 'descends directly from ActiveRecord::Base' do
    expect(described_class.superclass).to eq(ActiveRecord::Base)
  end

  it 'is an abstract class' do
    expect(described_class).to be_abstract_class
  end
end
