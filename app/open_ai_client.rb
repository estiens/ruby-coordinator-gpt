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
    @spinner = TTY::Spinner.new('[:spinner] Checking on that ...', format: :pulse_2)
    @mock_client = use_mock ? OpenAiMockClient.new : nil
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

  def set_mock_response(input, response)
    @mock_client.set_mock_response(input, response) if @mock_client
  end

  def clear_mock_responses
    @mock_client.clear_mock_responses if @mock_client
  end
end
