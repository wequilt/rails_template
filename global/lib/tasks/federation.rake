# frozen_string_literal: true

require 'rover'

namespace :graphql do
  namespace :federation do
    desc 'Upload the latest schema to Apollo Studio'
    task publish: :environment do
      abort('failed to publish via Rover') unless Rover.new(command: :publish).run
    end

    desc 'Check that the current schema is composable in the supergraph'
    task check: :environment do
      abort('failed to check via Rover') unless Rover.new(command: :check).run
    end

    namespace :admin do
      desc 'Upload the latest admin schema to Apollo Studio'
      task publish: :environment do
        abort('failed to publish via Rover') unless Rover.new(command: :publish, admin: true).run
      end

      desc 'Check that the current schema is composable in the supergraph'
      task check: :environment do
        abort('failed to check via Rover') unless Rover.new(command: :check, admin: true).run
      end
    end
  end
end
