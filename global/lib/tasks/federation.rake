# frozen_string_literal: true

require 'rover'

namespace :graphql do
  namespace :federation do
    desc 'Upload the latest schema to Apollo Studio'
    task publish: :environment do
      abort('failed to publish via Rover') unless Rover.new(:publish).run
    end

    desc 'Check that the current schema is composable in the supergraph'
    task check: :environment do
      abort('failed to check via Rover') unless Rover.new(:check).run
    end
  end
end
