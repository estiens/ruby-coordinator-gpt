class PromptBuilder
  def initialize(custom_prompts: [], goal: @goal, summary: nil, last_actions: [])
    @last_actions = last_actions
    @goal = goal
    @custom_prompts = custom_prompts
  end

  def worker_prompt
    "#{prompt_start}\n#{prompt_commands}\n#{prompt_workspace}\nYour last few actions: #{@last_actions.join(',')}\nIf you received relevant information from your memories, you dont have to repeat the command.\n#{prompts['prompt_end']}"
  end

  def prompt_start
    "#{prompts['prompt_start']}\nYour overarching goal is: #{@goal}."
  end

  def prompt_commands
    prompts['command_prompt'] + "\n"
  end

  def prompt_workspace
    "#{prompts['workspace_prompt']}/nYour workspace is at #{Config.workspace_path}. Your workspace currently contains: #{Dir.entries(Config.workspace_path)}"
  end

  def prompts
    @prompts ||= YAML.load_file("#{__dir__}/worker_prompts.yml")
  end
end
