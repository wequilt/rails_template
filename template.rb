# frozen_string_literal: true

require 'json'
require 'shellwords'

def add_secret(key, value)
  @secrets ||= {}
  @secrets[key] = value
end

def app_name
  @app_name ||= Dir.pwd.split('/').last
end

def development_config
  <<~CONFIG
    # Enable Bullet gem to detect N+1 queries
      Bullet.enable = true
      Bullet.rails_logger = true

      # Do not require auth from internal docker containers
      config.host_authorization = { exclude: ->(request) { request.host =~ /host.docker.internal/ } }
  CONFIG
end

def check_aws_capability!
  begin
    output = `aws sts get-caller-identity 2>&1`
    if output.include?('An error occurred')
      say "Error talking to AWS: #{output}"
      exit 1
    end
  rescue Errno::ENOENT
    puts "AWS CLI is not installed. Please install it from https://aws.amazon.com/cli/"
    exit 1
  end
end

def gem_if_original(name)
  @original_gemfile ||= IO.read("Gemfile")
  @original_gemfile.include?("gem \"#{name}\"") ? "gem '#{name}'\n" : nil
end

def port_offset
  @port_offset ||= ask(
    <<~HERE.chomp.gsub(/\s+/, ' ')
      Service number (if there are 2 other services this will be service 3).
      Used to generate port numbers in docker-compose.yml, etc. =>
    HERE
  ).to_i
end

def postgres?
  gem_if_original('pg').present?
end

def secret_string
  Shellwords.escape(@secrets.to_json)
end

def source_paths
  [File.expand_path(File.dirname(__FILE__))] + Array(super)
end

def create_or_update_secrets!
  %i[prod stage dev].each do |env|
    name = "#{env}/service-#{app_name}"
    action, color = :create, :green
    output = `aws secretsmanager create-secret --name #{name} --secret-string #{secret_string} 2>&1`
    if output.include?('ResourceExistsException')
      output = `aws secretsmanager put-secret-value --secret-id #{name} --secret-string #{secret_string} 2>&1`
      action, color = :update, :yellow
    end

    if output.include?('An error occurred')
      say "An error occurred creating secret in AWS Secrets Manager: #{output}"
      exit 1
    end
    say_status action, "#{name} (AWS Secrets Manager)", color
  end
end

check_aws_capability!

add_secret 'rds-master-password', SecureRandom.hex(32)
add_secret 'secret-key-base', SecureRandom.hex(64)

copy_file 'gitignore', '.gitignore', force: true
create_file '.ruby-gemset', app_name
copy_file '.rubocop.yml'
copy_file 'atlantis.yaml'
template 'docker-compose.yml.tt'
template 'Gemfile.tt', force: true
copy_file 'Guardfile'

graphql_subdirs = %w[enums fields interfaces mutations scalars types]

inside 'app' do
  inside 'controllers' do
    copy_file 'graphql_controller.rb'
  end

  inside 'graphql' do
    copy_file 'schema.rb'

    graphql_subdirs.each do |dir|
      inside(dir)  { copy_file 'base.rb' }
    end

    inside('fields') { copy_file '.rubocop.yml' }
    inside('scalars') { copy_file '.rubocop.yml' }

    inside 'types' do
      copy_file 'error.rb'
      copy_file 'query.rb'
      copy_file 'viewer.rb'
      copy_file 'mutation.rb'
    end
  end

  inside 'policies' do
    copy_file 'application_policy.rb'
    copy_file 'authentication_failed.rb'
    copy_file 'authorization_failed.rb'

    inside 'mutations' do
      copy_file '.rubocop.yml'
    end

    inside 'types' do
      copy_file 'mutation_policy.rb'
      copy_file 'query_policy.rb'
      copy_file 'viewer_policy.rb'
    end
  end

  inside 'models' do
    copy_file 'user.rb'
  end
end

inside 'config' do
  template 'database.yml.tt', force: true if postgres?
  copy_file 'routes.rb', force: true
  inside 'environments' do
    copy_file '.rubocop.yml'
  end
  inside 'initializers' do
    copy_file 'datadog.rb'
  end
end

inside 'helm' do
  template 'Chart.yaml.tt'
  copy_file 'values.yaml'
  inside 'templates' do
    template 'deployment.yaml.tt'
    template 'migration.yaml.tt' if postgres?
    template 'service.yaml.tt'
    copy_file 'deployment_hpa.yaml'
    copy_file 'externalsecret.yaml'
  end
end

inside 'spec' do
  copy_file '.rubocop.yml'
  copy_file 'factories.rb'
  copy_file 'project_spec.rb'
  copy_file 'rails_helper.rb'
  copy_file 'spec_helper.rb'

  inside 'controllers' do
    copy_file 'application_controller_spec.rb'
    copy_file 'graphql_controller_spec.rb'
  end

  inside 'graphql' do
    copy_file 'schema_spec.rb'

    graphql_subdirs.each do |dir|
      inside(dir) { copy_file 'base_spec.rb' }
    end

    inside 'types' do
      copy_file 'viewer_spec.rb'
    end
  end

  inside 'models' do
    copy_file 'application_record_spec.rb'
    copy_file 'user_spec.rb'
  end

  inside 'policies' do
    copy_file 'application_policy_spec.rb'
    copy_file 'authentication_failed_spec.rb'
    copy_file 'authorization_failed_spec.rb'
  end

  inside 'support' do
    copy_file '.rubocop.yml'
    copy_file 'graphql_context.rb'
    copy_file 'graphql_inspection_helpers.rb'
    copy_file 'graphql_mutation_context.rb'
    copy_file 'graphql_shared_context.rb'
    copy_file 'graphql_type_context.rb'
    copy_file 'user_helpers.rb'
  end
end
run 'rm -rf test'

inside 'terraform' do
  template 'irsa.tf.tt'
  template 'main.tf.tt'
  template 'rds.tf.tt' if postgres?
  template 'remote_state.tf.tt'
  copy_file 'secrets.tf'
end

create_or_update_secrets!

%i[development test].each do |env|
  gsub_file "config/environments/#{env}.rb", /# Settings specified here.*$/, development_config
  template '.env.tt', ".env.#{env}"
end

gsub_file 'config/environments/production.rb', /# Use default logging formatter.*(# Do not dump schema)/m do |_match|
  <<~LOGRAGE.chomp
    # Configure Lograge to output logs as a single line of JSON per request
      config.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new($stdout))
      config.lograge.enabled = true
      config.lograge.base_controller_class = 'ActionController::API'
      config.lograge.formatter = Lograge::Formatters::Json.new
      config.lograge.logger = ActiveSupport::Logger.new($stdout)

      config.lograge.custom_payload do |controller|
        if controller.is_a?(GraphqlController)
          {
            operation: controller.operation_name,
            query: controller.query,
            variables: controller.variables,
            user_id: controller.context[:current_user]&.id
          }
        end
      end

      config.lograge.custom_options = lambda do |event|
        {}.tap do |options|
          unless event.payload[:exception_object].nil?
            options[:exception] = {
              backtrace: event.payload[:exception_object].backtrace,
              message: event.payload[:exception_object].message
            }
          end
        end
      end

      # Do not dump schema
  LOGRAGE
end

run 'rubocop -A -f quiet'
