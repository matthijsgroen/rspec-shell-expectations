require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

def spec(task)
  task.verbose = false
  task.rspec_opts = '--format documentation'
  task.rspec_opts << ' --color'
end

RSpec::Core::RakeTask.new(:spec_bash_stub) do |t|
  ENV['RSPEC_BASH_STUB_TYPE'] = :bash_stub.to_s
  spec(t)
end

RSpec::Core::RakeTask.new(:spec_ruby_stub) do |t|
  ENV['RSPEC_BASH_STUB_TYPE'] = :ruby_stub.to_s
  spec(t)
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task spec: [:spec_bash_stub, :spec_ruby_stub]
task default: [:rubocop, :spec]
