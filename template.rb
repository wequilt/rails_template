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
    <<~HERE.chomp.gsub(/\s+/, ' '),
      Service number (if there are 2 other services this will be service 3).
      Used to generate port numbers in docker-compose.yml, etc'
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

add_secret('rds-master-password', SecureRandom.hex(32))

copy_file '.rubocop.yml'
copy_file 'atlantis.yaml'
template 'docker-compose.yml.tt'
template 'Gemfile.tt', force: true

environment "Bullet.enable = true\nBullet.rails_logger = true", env: %i[development test] if postgres?

inside 'config' do
  template 'database.yml.tt', force: true if postgres?
end

inside 'terraform' do
  template 'remote_state.tf.tt'
  template 'rds.tf.tt' if postgres?
  template 'main.tf.tt'
end

create_or_update_secrets!
