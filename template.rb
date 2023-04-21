# frozen_string_literal: true

def source_paths
  [File.expand_path(File.dirname(__FILE__))] + Array(super)
end

template 'Gemfile.tt', force: true
copy_file '.rubocop.yml'

