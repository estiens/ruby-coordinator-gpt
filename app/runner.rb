require 'json'
require 'pry'
require_relative 'includes'

class Runner

  def self.console
    binding.pry
  end

  def initialize(objective: 'compile lists and description of the most used ruby gems in each of the past ten years')
    # @config = Config.new
    # @available_workers = BaseWorker.available_workers
    @plan = nil
    @current_workers = []
    @workspace = './workspace'
    # @database = PostgresMemory.new
    # make_request(prompt)
    make_worker
  end

  def make_worker
    worker = Worker.new(name: 'web_search',
                        goal: 'search for the best ruby gems for making games and compile a document about the top 10')
    @current_workers << worker
    binding.pry
  end

  def prompt
    base_prompt + current_status_prompt + workspace_prompt + current_workers_prompt + end_prompt
  end

  def make_request(prompt)
    response = OpenAiClient.system_chat(prompt)
    puts JSON.parse(response)
  end

  def workspace_prompt
    'There are currently no files in your workspace'
  end

  def current_workers_prompt
    return 'You currently have no workers' if @current_workers.empty?

    string = "You currently have the following workers:\n"
    string += @current_workers.map { |worker| "worker_name: #{worker.name}, status: #{worker.status}" }.join('\n')
    string
  end

  def current_status_prompt
    return 'You currently have no status' if @current_status.nil?

    ''"
    The most recent thing you did was:
    #{@current_status}
    "''
  end

  def end_prompt
    "You should only respond in a JSON format. Your response must be valid JSON and be in the following format:

    ```json
    {
      plan: paragraph about your overall plan,
      tasks_accomplished: your accomplishments so far,
      reflections: anything you have learned so far, what has worked or hasn't worked
      next_step: the next thing you want to try to accomplish as an English sentence
      command: exactly one command that you want to execute
      current_rating: a current rating from 1-10 on how you think things are going.
    }
    ```

    the create_worker command should be issued in the following format:
    {
        command: create_worker,
        worker_goal: A suggested goal for the worker in 1-5 sentences along with a few commands it could possibly use.
        deliverable: a suggested deliverable for the worker in 1-5 sentences.
        worker_name: a name for the worker.
    }

    the read_files or write_files command should include the following:
    {
      command: read_files or write_files
      file_name: the name of the file you want to read or write to.
      file_contents: the contents of the file you want to write to.
    }

    the wait command can simply be: {command: wait}

    It is important you only respond in valid JSON."
  end

  def base_prompt
    ''"
    You are an autonomous AI task completion platform that can create workers. Your workers have the following abilities: search_web, create_file, edit_file, delete_file, execute_shell_command, read_website, summarize_text.

    Your objective is to:

    You are currently just starting so you have no workers

    Your workers will work in parallel, so please only assign them tasks that can be done simultaneously. When they finish you will receive a report of their deliverables. I will continually report back to you the status of their progress, and you can decide your next steps. You can read_files, write_files, create_worker, or ask_user_question, or simply wait.
    "''
  end
end

Runner.console
