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

def bullet_config
  <<~BULLET
    Bullet.enable = true
    Bullet.rails_logger = true
  BULLET
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

copy_file '.rubocop.yml'
copy_file 'atlantis.yaml'
template 'docker-compose.yml.tt'
template 'Gemfile.tt', force: true


inside 'config' do
  template 'database.yml.tt', force: true if postgres?
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

inside 'terraform' do
  template 'irsa.tf.tt'
  template 'main.tf.tt'
  template 'rds.tf.tt' if postgres?
  template 'remote_state.tf.tt'
  copy_file 'secrets.tf'
end

create_or_update_secrets!

%i[development test].each do |env|
  environment bullet_config, env: env if postgres?
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
