require_relative '../includes'
class Worker
  attr_reader :name, :task, :status

  def initialize(name: 'code',
                 goal: 'The code that runs you lives on this computer, see if you can find it.')
    @name = name
    @goal = goal
    @status = :in_progress
    @current_thought = nil
    @last_action = nil
    @messages = []
    @memory = PostgresMemory.new
    @spinner = TTY::Spinner.new('[:spinner]', format: :pulse_2)
  end

  def run
    return nil if @status == :success || @status == :failure

    context = @memory.get_context("#{@goal}, #{@last_action}, #{@current_thought}")
    binding.pry

    puts "Current context: #{context}"
    puts "Current thought: #{@current_thought}"
    puts "Last action: #{@last_action}"

    next_steps = request_next_step(context: "#{context} #{@current_thought} Last Action: #{@last_action}")
    @messages << { role: 'assistant', content: format_next_steps(next_steps) }
    @current_thought = next_steps[:thought]
    action_result = take_action_from(next_steps)
    @memory.add_memory(format_next_steps(next_steps) + "RESULT: #{action_result}")
    run
  end

  def format_next_steps(next_steps)
    "THOUGHT: #{next_steps[:thought]}\nCOMMAND: #{next_steps[:command]}\nARGUMENTS:#{next_steps[:arguments]}\nREFLECTIONS: #{next_steps[:reflections]}"
  end

  def take_action_from(next_steps)
    command = next_steps[:command]
    arguments = next_steps[:arguments]
    args = {}
    arguments&.each { |k, v| args[k.to_sym] = v }
    result = action_dispatcher(command: command, args: args)
    @last_action = "Your last action was #{command} with args #{args}"
    result
  end

  def open_ai
    OpenAiClient.new(messages: @messages.last(2))
  end

  # def parse_json_or_retry(json_string)
  #   JSON.parse(json_string)
  # rescue JSON::ParserError
  #   message = "I got a parsing error, please return this string in JSON parseable by ruby's JSON.parse #{json_string}"
  #   puts message
  #   @messages << { role: 'user', content: message }
  #   response = open_ai.chat_with_gpt_3_5_turbo
  #   extract_data_from_response(response)
  # end

  def extract_data_from_response(response)
    match = response.match(/^THOUGHT:\s*(?<thought>.+)\nCOMMAND:\s*(?<command>.+)\nARGUMENTS:\s*(?<args>.+)\nREFLECTIONS:\s*(?<reflections>.*)(?<!\n)$/m)
    return response if match.nil?

    hash = {}
    hash[:thought] = match[:thought]
    hash[:command] = match[:command]

    # Parse the arguments
    args_str = match[:args]
    args = args_str.split(',').map do |arg|
      k, v = arg.strip.split('=')
      [k.to_sym, v]
    end.to_h
    hash[:arguments] = args
    hash[:argument_string] = args_str
    hash[:reflections] = match[:reflections]
    hash
  end

  def clean_and_balance_json_string(json_string)
    # Remove outer double quotes if they exist
    json_string = json_string[1..-2] if json_string.start_with?('"') && json_string.end_with?('"')

    # Escape single quotes instead of replacing them with double quotes
    json_string.gsub!("'", "\\'")

    # Correctly escape special characters in the value strings
    json_string = json_string.gsub(/:(\s*)"(.*?)(?<!\\)"/) do |_match|
      escaped_string = Regexp.last_match(2).gsub(/(?!\\)"/, '\"').gsub(/\\\\(?=(?!")\\")/, '\\')
      ":#{Regexp.last_match(1)}\"#{escaped_string}\""
    end

    # Balance brackets
    opening_braces = json_string.scan('{').length
    closing_braces = json_string.scan('}').length
    (opening_braces - closing_braces).times { json_string << '}' }

    json_string
  end

  def action_dispatcher(command:, args:)
    klass = find_service(command)
    return 'Could not find that command' if klass.nil?

    Object.const_get("Services::#{klass}").new(command: command.to_sym, args: args).run
  end

  def find_service(command)
    worker_commands.select { |k, _v| k == command.to_sym }.values.first
  end

  def find_current_context; end

  def request_next_step(context: '')
    @messages << { role: 'user', content: worker_prompt + "/n--/nContext: #{context}" }
    response = open_ai.worker_chat
    extract_data_from_response(response)
  end

  def worker_prompt
    prompts = YAML.load_file('prompts/worker_prompts.yml')
    prompt = prompts['prompt_start'] + "\n"
    prompt += "Your overarching goal is: #{@goal}."
    prompt += prompts['command_prompt'] + "\n"
    prompt += prompts['workspace_prompt']
    prompt += "\nYour workspace currently contains: #{Dir.entries(Config.workspace_path)}\n"
    prompt += "Your available commands are: #{worker_abilities.map do |a|
                                                a[:command]
                                              end.join(', ')}\n"
    prompt += prompts['prompt_end']
    prompt
  end

  def available_commands
    @available_commands ||= YAML.load_file('lib/services/available_commands.yml')
  end

  def worker_commands
    available_commands.flat_map do |_service, info|
      info['commands'].map do |com|
        [com, info['klass']]
      end
    end.to_h
  end

  def worker_abilities
    available_commands.map do |service, info|
      { service: service, description: info['description'],
        arguments: info['arguments'], command: info['commands'], args: info['args'] }
    end
  end
end

puts Worker.new.run
