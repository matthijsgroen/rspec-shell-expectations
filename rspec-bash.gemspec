# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'rspec-bash'
  spec.version       = '0.0.3'
  spec.authors       = ['Ben Brewer', 'Mike Urban', 'Matthijs Groen']
  spec.email         = ['ben@benbrewer.me', 'mike.david.urban@gmail.com']
  spec.summary       = 'Test Bash with RSpec'
  spec.description   = <<-DESCRIPTION
    Stub and mock Bash commands
    Verify Bash calls and outputs
  DESCRIPTION
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
end
