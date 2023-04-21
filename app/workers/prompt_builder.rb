class PromptBuilder
  def initialize(custom_prompts: [], context_for_current_action: nil)
    @custom_prompts = []
  end

  def worker_prompt
    "#{prompt_start}\n#{prompt_commands}\n#{prompt_workspace}\n#{prompts['prompt_end']}"
  end

  def prompt_start
    "#{prompts['prompt_start']}\nYour overarching goal is: #{@goal}."
  end

  def prompt_commands
    prompts['command_prompt'] + "\n"
  end

  def prompt_workspace
    "#{prompts['workspace_prompt']}/nYour workspace currently contains: #{Dir.entries(Config.workspace_path)}"
  end

  def prompts
    @prompts ||= YAML.load_file('prompts/worker_prompts.yml')
  end
end
