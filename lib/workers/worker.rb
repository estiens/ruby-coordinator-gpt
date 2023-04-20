require_relative '../includes'
class Worker
  attr_reader :name, :task, :status

  def initialize(name: 'Research Worker', goal:'Summarize recent research into autonomous AI and create a file of learnings', status: :starting)
    @name = name
    @goal = goal
    @status = status
    @current_context = 0
    @messages = []
  end

  def run
    return nil if @status == :success || @status == :failure

    @status = :in_progress

    json_response = request_next_step
    @messages << { role: 'assistant', message: json_response }
    action = take_action_from(json_response)
  end

  def take_action_from(json_response)
    command = json_response['command']
    arguments = json_response['arg'] || json_response['args']
    args = {}
    arguments.each { |k,v| args[k.to_sym] = v }
    action_dispatcher(command: command, args: args)
  end

  def action_dispatcher(command:, args:)

  end

  def find_current_context; end

  def request_next_step
    @messages << { role: 'user', message: 'worker_prompt' }
    response = OpenAiClient.system_chat(worker_prompt)
    JSON.parse(response)
  rescue StandardError => e
    binding.pry
  end

  def worker_prompt
    prompts = YAML.load_file('prompts/worker_prompts.yml')
    prompt = prompts['prompt_start'] + worker_abilities.join(',')
    prompt += prompts['command_prompt']
    prompt += prompts['prompt_end']
    prompt
  end

  def available_commands
    @available_commands ||= YAML.load_file('lib/services/available_commands.yml')
  end

  def worker_commands
    available_commands.map { |_service, info| info['commands'] }.flatten
  end

  def worker_abilities
    available_commands.map do |service, info|
      { service: service, description: info['description'],
        arguments: info['arguments'], command: info['commands'], args: info['args'] }
    end
  end
end