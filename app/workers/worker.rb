require_relative '../includes'
require_relative 'memory_handler'
require_relative 'action_handler'

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
    result = ActionHandler.action_dispatcher(command: command, args: args)
    @last_action = "Your last action was #{command} with args #{args}"
    result
  end

  def open_ai
    OpenAiClient.new(messages: @messages.last(2))
  end

  def extract_data_from_response(response)
    MemoryHandler.extract_data_from_response(response)
  end

  def clean_and_balance_json_string(json_string)
    MemoryHandler.clean_and_balance_json_string(json_string)
  end

  def find_service(command)
    ActionHandler.find_service(command)
  end

  def find_current_context; end

  def request_next_step(context: '')
    @messages << { role: 'user', content: worker_prompt + "/n--/nContext: #{context}" }
    response = open_ai.worker_chat
    extract_data_from_response(response)
  end

  def worker_prompt
    # add context
    PromptBuilder.new.worker_prompt
  end

  def available_commands
    ActionHandler.available_commands
  end

  def worker_commands
    ActionHandler.worker_commands
  end

  def worker_abilities
    ActionHandler.worker_abilities
  end
end
