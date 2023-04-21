require_relative '../includes'

require_relative 'action_handler'
require_relative 'memory_handler'

require_relative '../prompts/prompt_builder'
class Worker
  attr_reader :name, :task, :status

  def self.logger
    @logger ||= Logger.new($stdout)
  end

  def self.spinner
    @spinner ||= Runner.spinner
  end

  def initialize(name: 'PublisherAI')
    @name = name
    @status = :in_progress
    @last_actions = []
    @summary_last_action = nil
    @actual_last_result = nil
    @context_from_memory = nil
    @messages = []
    @memory = Config.memory_module.new
    @counter = 0
  end

  def run
    return nil if @status == :success || @status == :failure

    logger.info("Round #{@counter} start")
    ask_for_human_input if (@counter % 5).zero?
    @context_from_memory = if @summary_last_action.nil?
                             ActionHandler.worker_abilities.join(',')
                           else
                             @memory.get_context(@summary_last_action)
                           end

    next_steps = request_next_step
    logger.info("\nNEXT_STEPS: #{next_steps.inspect}\n")

    @counter += 1

    take_action_from(next_steps)
    run
  end

  private

  def ask_for_human_input
    logger.info('Pausing to see if there is anything you want to add or correct')
    @input = gets.chomp
  end

  def logger
    self.class.logger
  end

  def spinner
    self.class.spinner
  end

  def formatted_thinking(next_steps)
    thinking = "---\nReasoning behing the action"
    thinking += "THOUGHT: #{next_steps[:thought]}\n"
    thinking += "COMMAND: #{next_steps[:command]}ARGUMENTS:#{next_steps[:arguments]}\n"
    thinking += "REFLECTIONS: #{next_steps[:reflections]}\n---"
    thinking
  end

  def take_action_from(next_steps)
    command, args = parse_command(next_steps)
    result = ActionHandler.action_dispatcher(command: command, args: args)
    @actual_last_result = "\n#{formatted_thinking(next_steps)}\nRESULT:#{result}"

    # add the last results to memory and get summary of it with advice
    @memory.add(@actual_last_result)
    if @actual_last_result.length < 2000
      @messages << { role: 'user', content: "This was your last command: #{@actual_last_result}" }
    end
    summarize_last_action

    @last_actions << "Your last action was #{command} with args #{args}"
  end

  def summarize_last_action
    to_summarize = @actual_last_result
    unless @last_actions.empty?
      to_summarize += "Previous Actions: #{@last_actions.last(3).join(',')}"
    end
    @summary_last_action = @memory.summarize_memory(to_summarize)
  end

  def parse_command(next_steps)
    command = next_steps[:command]
    arguments = next_steps[:arguments]
    args = {}
    arguments&.each { |k, v| args[k&.to_sym] = v }
    [command, args]
  end

  def open_ai
    messages = [
      { role: 'system', content: PromptBuilder.new.system_prompt_for_worker }, @messages.last(4)
    ].flatten
    binding.pry
    OpenAiClient.new(messages: messages)
  end

  def extract_data_from_response(response)
    MemoryHandler.extract_data_from_response(response)
  end

  # not using JSON at the moment
  def clean_and_balance_json_string(json_string)
    MemoryHandler.clean_and_balance_json_string(json_string)
  end

  # implement fuzzy find?
  def find_service(command)
    @status = :success if command == 'job_success'
    @status = :failure if command == 'job_failure'
    ActionHandler.find_service(command)
  end

  def request_next_step
    unless @context_from_memory.nil?
      context = "This is relevant information for you based on an action in the past:\n"
      context += @context_from_memory
      @messages << { role: 'user', content: context }
    end
    @messages << { role: 'user', content: worker_prompt }
    response = open_ai.chat
    extract_data_from_response(response)
  end

  def worker_prompt
    custom = []

    unless @input.nil?
      custom << ["This is advice being offered from a human that wants to help: #{@input}"]
      @input = nil
    end

    last3 = @last_actions.last(3)
    summary = @summary_last_action
    p = PromptBuilder.new(last_actions: last3, summary: summary, custom_prompts: custom)
    p.worker_prompt
  end
end
