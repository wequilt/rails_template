# frozen_string_literal: true

module Types
  class Health < Shared::Types::Base
    description 'Health of this server'

    shareable

    field :deep_check, Boolean, 'Run deep checks and return whether the server is healthy'
    field :shallow_check, Boolean, 'Run shallow checks and return whether the server is healthy'

    def deep_check
      ApplicationRecord.connection
      Rails.logger.info('Deep health check succeeded')
      true
    end

    def shallow_check
      Rails.logger.info('Shallow health check succeeded')
      true
    end

    def self.authorized?(_object, _context)
      true
    end
  end
end
