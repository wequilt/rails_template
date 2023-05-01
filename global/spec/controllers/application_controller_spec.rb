# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController do
  it 'extends from ActionController::API' do
    expect(described_class.new).to be_a(ActionController::API)
  end
end
