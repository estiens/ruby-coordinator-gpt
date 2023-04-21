require 'openai'
require_relative 'config'
require_relative 'open_ai_mock_client'

class OpenAiClient
  attr_accessor :client, :messages, :mock_client

  def self.get_embeddings(text)
    client = OpenAI::Client.new(access_token: Config.open_ai_api_key)
    client.embeddings(parameters: { input: [text], model: 'text-embedding-ada-002' })
  end

  def self.spinner
    @spinner = Runner.spinner
  end

  def initialize(messages: [], model: 'gpt-4', temperature: 0.9, use_mock: false)
    @use_mock = use_mock
    @client = set_client
    @model = model
    @temperature = temperature
    @messages = messages
    @mock_client = use_mock ? OpenAiMockClient.new : nil
  end

  def set_client
    return OpenAiMockClient if @use_mock

    OpenAI::Client.new(access_token: Config.open_ai_api_key)
  end

  def spinner
    @spinner ||= self.class.spinner
  end

  def chat(model: nil)
    spinner.auto_spin
    model ||= @model
    response = client.chat(
      parameters: {
        model: model,
        messages: @messages,
        temperature: @temperature
      }
    )
    spinner.stop
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

  def summarize_memory(to_be_summarized)
    @messages = [
      { role: 'user',
        content: "You are a summarizer for AI autonomous agents. This is a report back of the most recent action one took, please provide a summary of what happened, and whether it appeared successful or not. Make sure to include it's action. If it was successful remind it of what it succeeded at. If it retrieved pertinent information, please keep all hyperlinks and useful info. If it's logic seems faulty correct it. I will also send you it's previous action, if it appears to be doing the same thing, help it.\n---\n#{to_be_summarized}" }
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

  # TODO: Figure out saving mocked responses

  def set_mock_response(input, response)
    @mock_client&.set_mock_response(input, response)
  end

  def clear_mock_responses
    @mock_client&.clear_mock_responses
  end
end
