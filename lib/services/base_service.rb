module Services
  class BaseService
    def initialize(command:, args: {})
      raise ArgumentError, 'You must provide a command' if command.nil?

      @command = command
      @args = args
    end

    def available_commands
      raise NotImplementedError
    end

    def run
      method = command_mapping[@command]
      return "Invalid command, the commands I have are #{command_mapping}" if method.nil?

      public_send(method)
    rescue StandardError => e
      e.message
    end

    private

    def command_mapping
      raise NotImplementedError
    end
  end
end
