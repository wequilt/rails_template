# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationPolicy do
  describe '#authorized?' do
    it 'must be implemented' do
      expect { described_class.new.authorized? }.to raise_error(NotImplementedError)
    end
  end
end
