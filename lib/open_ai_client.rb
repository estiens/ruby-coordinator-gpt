require 'openai'
require_relative 'config'

class OpenAiClient
  attr_accessor :client, :messages

  def self.get_embeddings(text)
    client = OpenAI::Client.new(access_token: Config.open_ai_api_key)
    client.embeddings(parameters: { input: [text], model: 'text-embedding-ada-002' })
  end

  def initialize(messages: [], model: 'gpt-4', temperature: 0.7)
    @client = OpenAI::Client.new(access_token: Config.open_ai_api_key)
    @model = model
    @temperature = temperature
    @messages = messages
    @spinner = TTY::Spinner.new('[:spinner] Checking on that ...', format: :pulse_2)
  end

  def chat(model: nil)
    puts "STARTING CHAT WITH MESSAGES: #{@messages}"
    @spinner.auto_spin
    model ||= @model
    response = client.chat(
      parameters: {
        model: model,
        messages: @messages,
        temperature: @temperature
      }
    )
    @spinner.stop
    puts "RESPONSE #{response}"
    response['choices'][0]['message']['content']
  end

  def summarize_search(results)
    @messages = [{ role: 'user',
                   content: "Please summarize these results from a search engine. Here are the search results in JSON - please include the relevant hyperlinks to the original webpage - It should be in list form with the page title,the summary, and it must have the link to the original site, \n--\n#{results}" }]
    chat_with_gpt_3_5_turbo
  end

  def system_chat
    system_message = { role: 'system',
                       content: 'You are an autonomous AI task coordination and delivery platform that plans and executed projects by creating workers that can do a variety of tasks. You always respond in valid JSON and only valid JSON' }
    @messages.unshift(system_message)
    chat
  end

  def chat_with_gpt_3_5_turbo
    @messages = @messages.last(2)
    chat(model: 'gpt-3.5-turbo')
  end

  def chat_with_gpt_4
    @messages = @messages.last(2)
    chat(model: 'gpt-3.5.turbo')
  end

  def worker_chat
    system_message = { role: 'system',
                       content: 'You are an autonomous AI task worker that works towards a goal. Given the context of the current desired goal, you respond with the next action.' }
    @messages.unshift(system_message)
    chat
  end

  def summarize_memory(memory)
    @messages = [
      { role: 'user',
        content: "You are a summarizer for AI autonomous agents. This is a report back of the most recent action one took, please provide a brief summary of what happened, and whether it appeared successful or not. Add a section with any suggestions of your own. Lastly, if it seems to have problems running commands remind it that it can read it's available_commands.txt file. #{memory}"
      }
    ]
    chat_with_gpt_3_5_turbo
  end

  def summarize(text)
    @messages = [
      { role: 'user',
        content: "You are a state of the art text summarizer. Please summarize the following chunk of text, making it at most 2500 characters.Do your best to retain all important data points and hyper-links:\n\n#{text}" }
    ]
    chat_with_gpt_3_5_turbo
  end
end
