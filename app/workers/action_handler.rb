class ActionHandler

  def self.action_dispatcher(command:, args:)
    klass = find_service(command)
    return 'Could not find that command' if klass.nil?

    Object.const_get("Services::#{klass}").new(command: command.to_sym, args: args).run
  end

  def self.find_service(command)
    worker_commands.select { |k, _v| k == command.to_sym }.values.first
  end

  def self.worker_commands
    available_commands.flat_map do |_service, info|
      info['commands'].map do |com|
        [com, info['klass']]
      end
    end.to_h
  end

  def self.available_commands
    @available_commands ||= YAML.load_file('lib/services/available_commands.yml')
  end

  def self.worker_abilities
    available_commands.map do |service, info|
      { service: service, description: info['description'],
        arguments: info['arguments'], command: info['commands'], args: info['args'] }
    end
  end
end
