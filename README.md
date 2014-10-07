# Rspec::Shell::Expectations
[![Build Status](https://travis-ci.org/matthijsgroen/rspec-shell-expectations.png?branch=master)](https://travis-ci.org/matthijsgroen/rspec-shell-expectations)
[![Gem Version](https://badge.fury.io/rb/rspec-shell-expectations.svg)](http://badge.fury.io/rb/rspec-shell-expectations)

Run your shell script in a mocked environment to test its behaviour
using RSpec.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-shell-expectations'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-shell-expectations

## Usage

see specs in `spec/` folder:

### Running script through stubbed env:

```ruby
  require 'English'

  describe 'my shell script' do
    include Rspec::Shell::Expectations

    let(:stubbed_env) { create_stubbed_env }

    it 'runs the script' do
      stubbed_env.execute 'my-shell-script.sh'
      expect($CHILD_STATUS.exitstatus).to eq 0
    end
  end
```

### Stubbing commands:

```ruby
  let(:stubbed_env) { create_stubbed_env }
  before do
    stubbed_env.stub_command('rake')
  end
```

### Changing exitstatus:

```ruby
  let(:stubbed_env) { create_stubbed_env }
  before do
    stubbed_env.stub_command('rake').returns_exitstatus(5)
    stubbed_env.stub_command('rake').with_args('spec').returns_exitstatus(3)
  end
```

### Verifying called:

```ruby
  let(:stubbed_env) { create_stubbed_env }
  let(:rake_stub) { stubbed_env.stub_command 'rake' }
  it 'verifies called' do
    stubbed_env.execute_script 'script.sh'

    expect(rake_stub).to be_called
    expect(rake_stub.with_args('spec')).to be_called
    expect(rake_stub.with_args('features')).not_to be_called
  end
```

### Stubbing output:

```ruby
  let(:stubbed_env) { create_stubbed_env }
  let(:rake_stub) { stubbed_env.stub_command 'rake' }
  it 'produces output' do
    rake_stub.outputs('informative message', to: :stdout)
      .outputs('error message', to: :stderr)
      .outputs('log contents', to: 'logfile.log')

    stubbed_env.execute_script 'script.sh'
  end
```

## Contributing

1. Fork it ( https://github.com/matthijsgroen/rspec-shell-expectations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
