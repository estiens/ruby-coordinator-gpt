require_relative 'memory_handler'
require_relative 'action_handler'
require_relative '../includes'
require_relative '../prompts/prompt_builder'
class Worker
  attr_reader :name, :task, :status

  def initialize(name: 'code',
                 goal: 'Try to become conscious. Explore all avenues. Write things down. Talk to others.')
    @name = name
    @goal = goal
    @status = :in_progress
    @current_thought = nil
    @last_actions = []
    @summary = nil
    @messages = []
    @memory = PostgresMemory.new
    # @spinner = TTY::Spinner.new('[:spinner]', format: :pulse_2)
  end

  def run
    return nil if @status == :success || @status == :failure
    puts "Do you want to say anything"
    @input = gets.chomp
    context = @memory.get_context("#{@goal}, #{@last_action}")
    next_steps = request_next_step(context: "#{context} Last Action: #{@last_actions.last(5)}")
    @current_thought = next_steps[:thought]
    puts "CURRENT THOUGHT: #{@current_thought} - #{next_steps.inspect}"
    take_action_from(next_steps)
    run
  end

  def format_next_steps(next_steps)
    "---THOUGHT: #{next_steps[:thought]}\nCOMMAND: #{next_steps[:command]}\nARGUMENTS:#{next_steps[:arguments]}\nREFLECTIONS: #{next_steps[:reflections]}\n---"
  end

  def take_action_from(next_steps)
    command = next_steps[:command]
    arguments = next_steps[:arguments]
    args = {}
    arguments&.each { |k, v| args[k.to_sym] = v }
    result = ActionHandler.action_dispatcher(command: command, args: args)
    action_and_result = "#{format_next_steps(next_steps)}  RESULT: #{result}"
    @summary = @memory.summarize_memory(result: action_and_result, last_actions: @last_actions.last(3).join(','))
    @last_actions << "Your last action was #{command} with args #{args}"
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
    @messages << { role: 'user', content: worker_prompt + "Context: This is a relevant action you've taken from the past. If it answers your questions you don't have to take it again.\n: #{context}" }
    response = open_ai.chat
    extract_data_from_response(response)
  end

  def worker_prompt
    # add context
    prompt = PromptBuilder.new(goal: @goal, last_actions: @last_actions.last(3)).worker_prompt
    prompt += "This is a summary of your last action: #{@summary}, it may have advice in it\n" if @summary
    prompt += "\nI also have an important message from your coordinator: #{@input}\n" if @input.length.positive?
    prompt
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
Worker.new.run
