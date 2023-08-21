# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schema do
  let(:schema) { described_class }

  it_behaves_like 'a graphql schema'

  describe '.unauthorized_object' do
    subject(:unauthorized_object) { schema.unauthorized_object(nil) }

    it 'raises an AuthorizationFailed error' do
      expect { unauthorized_object }.to raise_error(AuthorizationFailed)
    end
  end
end
