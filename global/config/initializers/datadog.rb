# frozen_string_literal: true

Datadog.configure do |c|
  c.tracing.enabled = Rails.env.production? && !Rails.const_defined?('Console')
end
