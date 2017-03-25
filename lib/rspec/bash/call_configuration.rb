require 'yaml'

module Rspec
  module Bash
    class CallConfiguration
      attr_reader :command

      def initialize(config_path, command)
        @config_path = config_path
        @configuration = []
        @command = command
      end

      def set_exitcode(exitcode, args = [])
        current_conf = create_or_get_conf(args)
        current_conf[:exitcode] = exitcode
        write @configuration
      end

      def add_output(content, target, args = [])
        current_conf = create_or_get_conf(args)
        current_conf[:outputs] << {
          target: target,
          content: content
        }
        write @configuration
      end

      def call_configuration
        @config_path.open('r') do |conf_file|
          YAML.load(conf_file.read) || []
        end
      rescue NoMethodError, Errno::ENOENT
        return []
      end

      def call_configuration=(new_conf)
        write new_conf
      end

      private

      def write(call_conf_to_write)
        @config_path.open('w') do |conf_file|
          conf_file.write call_conf_to_write.to_yaml
        end
      end

      def create_or_get_conf(args)
        @configuration = call_configuration
        new_conf = {
          args: args,
          exitcode: 0,
          outputs: []
        }
        current_conf = @configuration.select { |conf| conf[:args] == args }
        @configuration << new_conf if current_conf.empty?
        current_conf.first || new_conf
      end
    end
  end
end
