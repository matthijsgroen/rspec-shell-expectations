require 'simplecov'
SimpleCov.start

require 'English'
require 'rspec/bash'
require 'socket'
require 'sparsify'
require 'tempfile'
require 'yaml'

require 'helper/string_file_io'
require 'helper/shared_tmpdir'

RSpec.configure do |c|
  c.include Rspec::Bash
end
