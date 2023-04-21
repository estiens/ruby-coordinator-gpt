class PromptBuilder
  def initialize(custom_prompts: [], goal: @goal, summary: nil, last_actions: [])
    @last_actions = last_actions
    @goal = goal
    @custom_prompts = custom_prompts
    @summary = summary
  end

  def worker_prompt
    prompt = "#{prompt_start}\n#{prompt_commands}\n#{prompt_workspace}\n"
    prompt += "Your last few actions: #{@last_actions.join(',')}"
    prompt += "Read this prompt carefully to see if it already has what you need.\n"
    if @summary
      prompt += "This is a summary of your last action: #{@summary}, it may have advice in it\n"
    end
    prompt += "#{prompts['prompt_end']}\n"
    prompt += @custom_prompts.join("\n")
    prompt
  end

  private

  def prompt_start
    prompt = "#{prompts['prompt_start']}\nYour overarching goal is: #{@goal}.\n"
    work_instructions = "#{Config.app_directory}/worker_directory/worker_instructions.txt"
    prompt += "You have instructions you should read at #{work_instructions}.\n"
    prompt += "There is also available_commands.yml that lists all the commands you can use.\n"
    prompt += "You can also use shell commands.\n"
    prompt += "You cannot make up your own commands.\n"
    prompt += 'There is also a file called learnings.txt where you should write down anything'
    prompt += 'that you want to remember. You are forgetful, so I will use that to remind you.'
    prompt
  end

  def prompt_commands
    "#{prompts['command_prompt']}\n"
  end

  def prompt_workspace
    prompt = "#{prompts['workspace_prompt']}/nYour workspace is at #{Config.workspace_path}.\n"
    prompt += "Your workspace currently contains: #{Dir.entries(Config.workspace_path)}\n"
    learnings = File.read(File.open(
                            "#{Config.app_directory}/worker_instructions/learnings.txt", 'r'
                          ))
    prompt += "You also wanted to remember the following things: #{learnings}"
    prompt
  end

  def prompts
    @prompts ||= YAML.load_file("#{__dir__}/worker_prompts.yml")
  end
end
