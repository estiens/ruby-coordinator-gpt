require_relative 'base_service'

module Services
  class ShellCommandService < BaseService
    DISALLOWED_COMMANDS = %w[rm sudo].freeze

    def initialize(command: nil, args: {})
      super(command: command, args: args)
      @shell_command = args[:shell_command] || args[:command] || args[:cmd]
    end

    def available_commands
      %i[run_shell_command]
    end

    def command_mapping
      {
        run_shell_command: :run_shell_command
      }
    end

    def run_shell_command
      raise ArgumentError, "The proper syntax is command: run_shell_command, arguments: shell_command='ls'" if @shell_command.nil?
      if disallowed_command?(@shell_command)
        raise ArgumentError, 'This shell command is not allowed'
      end

      `#{@shell_command} 2>&1`
    end

    private

    def disallowed_command?(command)
      DISALLOWED_COMMANDS.any? { |disallowed| command.include?(disallowed) }
    end
  end
end