require 'openai'
require_relative 'config'
require_relative 'open_ai_mock_client'

class OpenAiClient
  attr_accessor :client, :messages, :mock_client

  def self.get_embeddings(text)
    client = OpenAI::Client.new(access_token: Config.open_ai_api_key)
    client.embeddings(parameters: { input: [text], model: 'text-embedding-ada-002' })
  end

  def initialize(messages: [], model: 'gpt-4', temperature: 0.7, use_mock: false)
    @client = use_mock ? OpenAiMockClient.new : OpenAI::Client.new(access_token: Config.open_ai_api_key)
    @model = model
    @temperature = temperature
    @messages = messages
    # @spinner = TTY::Spinner.new('[:spinner] Checking on that ...', format: :pulse_2)
    @mock_client = use_mock ? OpenAiMockClient.new : nil
  end

  def chat(model: nil)
    model ||= @model
    response = client.chat(
      parameters: {
        model: model,
        messages: @messages,
        temperature: @temperature
      }
    )
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

  def summarize_memory(memory, previous_action)
    @messages = [
      { role: 'user',
        content: "You are a summarizer for AI autonomous agents. This is a report back of the most recent action one took, please provide a summary of what happened, and whether it appeared successful or not. Make sure to include it's action. If it was successful remind it of what it succeeded at. If it retrieved pertinent information, please keep all hyperlinks and useful info. If it's logic seems faulty correct it. I will also send you it's previous action, if it appears to be doing the same thing, help it. Most recent action: #{memory}, Previous action: #{previous_action}" }
    ]
    chat_with_gpt_3_5_turbo
  end

  def get_summary(text)
    @messages = [
      { role: 'user',
        content: "You are a state of the art text summarizer. Please summarize the following chunk of text, making it at most 2500 characters. Do your best to retain all important data points and hyper-links:\n\n#{text}" }
    ]
    chat_with_gpt_3_5_turbo
  end

  def set_mock_response(input, response)
    @mock_client.set_mock_response(input, response) if @mock_client
  end

  def clear_mock_responses
    @mock_client.clear_mock_responses if @mock_client
  end
end
