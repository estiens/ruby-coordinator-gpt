class Worker
  attr_reader :name, :task, :status

  def initialize(name:, goal:, status: :starting)
    @name = name
    @goal = goal
    @status = status
    @current_context = 0
    @messages = []
  end

  def run
    return nil if @status == :success || @status == :failure

    @status = :in_progress

    response = JSON.parse(request_next_step)
    @messages << { 'role': 'assistant', 'message': response['thought'] }
  end

  def find_current_context
  end

  def request_next_step
    @messages << { 'role': 'user', 'message': 'worker_prompt' }
    response = OpenAiClient.system_chat(worker_prompt)
    JSON.parse(response)
  end

  def prompt_start
    prompt = "You are a worker that can #{worker_abilities} created by an autonomous system\n"
    prompt += "Your current task is: #{@goal}\n"
    prompt += 'You are to run indepently without user input. You should think about your plan,'
    prompt += "review what has happened, and decide on the next step. Carefully consider your next command.\n"
    prompt += "Use only non-interactive shell commands.\n"
    prompt
  end

  def worker_prompt
    prompt = prompt_start
    prompt += "When you have achieved the objective, you may issue the command job_success or job_failure
    depending on the results. Otherwise, respond with a JSON-encoded dict containing one of the
    commands: #{worker_abilities.join('/ ')}"

    prompt += "\nYour workspace is the './workspace' directory -
    you may create subdirectories as needed but you may not create files outside of the workspace directory."

    prompt += "\nYour response should look like: {'thought': '[REASONING]', 'cmd': '[COMMAND]', 'arg': '[ARGUMENT]'}"

    prompt += "Examples:\n"
    prompt += "{'thought': 'First, I will search for websites relevant to salami pizza.',
    'cmd': 'web_search', 'arg': 'salami pizza'}"
    prompt += "{'thought': I am going to scrape information about Apples.',
    'cmd': 'web_scrape', 'arg': 'https://en.wikipedia.org/wiki/Apple'}"
    prompt += 'IMPORTANT: ALWAYS RESPOND ONLY WITH THIS EXACT JSON FORMAT.'
    prompt += 'DOUBLE-CHECK YOUR RESPONSE TO MAKE SURE IT CONTAINS VALID JSON.'
    prompt += 'DO NOT INCLUDE ANY EXTRA TEXT WITH THE RESPONSE'
    prompt.strip
  end

  def worker_abilities
    %i[search_web write_file read_file read_website execute_shell_command summarize_text list_directory
       create_file edit_file delete_file job_success job_failure]
  end
end
