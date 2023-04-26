# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Each file in app directory' do # rubocop:disable RSpec/DescribeClass
  # EXCLUDE_DIRS = %w[graphql/enums graphql/fields policies/mutations policies/types].freeze
  EXCLUDE_DIRS = [].freeze
  EXCLUDE_FILES = [].freeze

  APP_PATH = Pathname.new(Rails.root).join('app')

  class << self
    def include_dir?(dir)
      EXCLUDE_DIRS.none? { |excluded| dir.start_with?(APP_PATH.join(excluded).to_path) }
    end

    def include_file?(dir)
      EXCLUDE_FILES.exclude?(dir.sub(APP_PATH.to_path, '').sub(%r{^/}, ''))
    end

    def app_dirs
      Dir.glob(APP_PATH.join('**', '*')).select do |path|
        next unless File.directory?(path) && include_dir?(path)

        Pathname.new(path).relative_path_from(APP_PATH).to_path
      end
    end
  end

  def spec_path(file_path)
    file_path.sub('/app/', '/spec/').sub('.rb', '_spec.rb')
  end

  app_dirs.each do |dir|
    Dir[APP_PATH.join("#{dir}/*.rb")].each do |file_path|
      next unless include_file?(file_path)

      it "has a spec file for '#{file_path}'" do
        expect(File).to exist(spec_path(file_path))
      end
    end
  end
end
