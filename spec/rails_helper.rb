# frozen_string_literal: true

unless ENV['SKIP_COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start('rails')
end

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit(1)
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.define_derived_metadata(file_path: %r{spec/graphql/types/}) do |meta|
    meta[:type] ||= :graphql_type
  end

  config.define_derived_metadata(file_path: %r{spec/graphql/mutations/}) do |meta|
    meta[:type] ||= :graphql_mutation
  end

  %w[graphql policies].each do |type|
    config.define_derived_metadata(file_path: %r{/spec/#{type}/}) do |meta|
      meta[:type] ||= type.singularize.to_sym
    end
  end

  config.include(FactoryBot::Syntax::Methods)
  # config.include(GraphQLContext, type: :graphql)
  # config.include(GraphQLInspectionHelpers)
  # config.include(GraphQLMutationContext, type: :graphql_mutation)
  # config.include(GraphQLTypeContext, type: :graphql_type)
  # config.include(UserHelpers)
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework(:rspec)
    with.library(:rails)
  end
end

RSpec::Matchers.define(:string_containing) do |x|
  match { |actual| actual.include?(x) }
end

Faker::Config.locale = 'en-US'
