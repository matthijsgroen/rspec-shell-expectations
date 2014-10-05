# Rspec::Shell::Expectations
[![Build Status](https://travis-ci.org/matthijsgroen/rspec-shell-expectations.png?branch=master)](https://travis-ci.org/matthijsgroen/rspec-shell-expectations)

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
  require 'English'

  describe 'my shell script' do
    include Rspec::Shell::Expectations

    let(:stubbed_env) { create_stubbed_env }
    before do
      stubbed_env.stub_command('rake')
    end

    it 'runs the script' do
      stubbed_env.execute 'my-shell-script.sh'
      expect($CHILD_STATUS.exitstatus).to eq 0
    end
  end
```

## Contributing

1. Fork it ( https://github.com/matthijsgroen/rspec-shell-expectations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
