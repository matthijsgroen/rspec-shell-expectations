# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/shell/expectations/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-shell-expectations'
  spec.version       = Rspec::Shell::Expectations::VERSION
  spec.authors       = ['Matthijs Groen']
  spec.email         = ['matthijs.groen@gmail.com']
  spec.summary       = 'Fake execution environments to TDD shell scripts'
  spec.description   = <<-DESCRIPTION
    Stub results of commands.
    Assert calls and input using RSpec for your shell scripts
  DESCRIPTION
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
end
