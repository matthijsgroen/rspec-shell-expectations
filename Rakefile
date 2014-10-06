require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'cucumber'
require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = 'features --strict --format progress'
end

task default: [:rubocop, :features, :spec]
