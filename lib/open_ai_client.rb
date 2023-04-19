require 'openai'
require_relative 'config'

class OpenAiClient
  attr_accessor :client

  def self.config
    @config ||= Config.new
  end

  def self.client
    @client ||= OpenAI::Client.new(access_token: Config.new.open_ai_api_key)
  end

  def self.system_chat(message)
    messages = [
      { role: 'system',
        content: 'You are an autonomous AI task coordination and delivery platform that plans and executed projects by creating workers that can do a variety of tasks. You always respond in valid JSON and only valid JSON' },
      { role: 'user', content: message }
    ]

    puts messages

    response = client.chat(
      parameters: {
        model: 'gpt-4',
        messages:,
        temperature: 0.7
      }
    )
    puts response
    response['choices'][0]['message']['content']
  end

  def self.get_embeddings(text)
    client.embeddings(parameters: { input: [text], model: 'text-embedding-ada-002' })
  end

  def self.summarize_search_instructions
    [
      { role: 'user',
        content: 'The following are search engine results. I would like a list of each search engine result, the link to the that result, and a summary of what it contains. It must include the link to each search result so that we can scrape them.' }
    ]
  end

  def self.summarize_memory_instructions(chunk)
    [
      { role: 'user',
        content: 'Shorten the following memory chunk of an autonomous agent from a first person perspective, 2000 tokens max.' },
      { role: 'user',
        content: "Do your best to retain all semantic information including tasks performed by the agent, website content, important data points and hyper-links:\n\n#{chunk}" }
    ]
  end

  def self.summarize_text_instructions(chunk)
    [
      { role: 'user',
        content: 'You are a state of the art text summarizer. Please summarize the following chunk of text, making it at most 2500 characters.' },
      { role: 'user',
        content: "Do your best to retain all important data points and hyper-links:\n\n#{chunk}" }
    ]
  end

  def self.summarize_memory(data)
    data = [data] unless data.is_a?(Array)
    data.map { |chunk| get_summary(text: chunk, agent_memory: true) }
  end

  # def self.summarize_text_chunks(chunks)
  #   existing_summaries = []
  #   binding.pry
  #   chunks.length.times do |i|
  #     binding.pry
  #     existing_summaries << get_chunk_summary(chunks[i - 1], existing_summaries)
  #   end
  #   existing_summaries
  # end

  # def self.get_chunk_summary(chunk, existing_summaries)
  #   messages = summarize_chunk_instructions(chunk, existing_summaries)
  #   puts messages
  #   response = client.chat(
  #     parameters: {
  #       model: config.fast_model, # Required.
  #       messages:,
  #       temperature: 0.5
  #     }
  #   )
  #   puts response
  #   response['choices'][0]['message']['content']
  # end

  def self.summarize_search(results)
    spinner = TTY::Spinner.new('[:spinner] Summarizing search results...', format: :pulse_2)
    spinner.auto_spin
    messages = summarize_search_instructions
    messages << { role: 'user', content: "Here are the search results in JSON - please include hyperlinks #{results}" }
    response = client.chat(
      parameters: {
        model: config.fast_model, # Required.
        messages:,
        temperature: 0.5
      }
    )
    spinner.stop
    response['choices'][0]['message']['content']
  end

  def self.get_summary(text:, agent_memory: false)
    messages = agent_memory ? summarize_memory_instructions(text) : summarize_text_instructions(text)
    response = client.chat(
      parameters: {
        model: config.fast_model, # Required.
        messages:,
        temperature: 0.5
      }
    )
    response['choices'][0]['message']['content']
  end
end
