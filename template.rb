# frozen_string_literal: true

def app_name
  @app_name ||= Dir.pwd.split('/').last
end

def check_aws_capability!
  begin
    output = `aws sts get-caller-identity 2>&1`
    if output.include?('An error occurred')
      puts "Error talking to AWS: #{output}"
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

def source_paths
  [File.expand_path(File.dirname(__FILE__))] + Array(super)
end

template 'Gemfile.tt', force: true
copy_file '.rubocop.yml'
template 'docker-compose.yml.tt'

environment "Bullet.enable = true\nBullet.rails_logger = true", env: %i[development test] if postgres?

inside 'config' do
  template 'database.yml.tt', force: true if postgres?
end
