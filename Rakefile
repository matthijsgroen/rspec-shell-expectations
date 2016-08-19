require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
  t.rspec_opts = '--format documentation'
  t.rspec_opts << ' --color'
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: [:rubocop, :spec]
