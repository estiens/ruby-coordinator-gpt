require 'tiktoken_ruby'
require_relative '../open_ai_client'

class BaseMemory
  def initialize
    @config = Config.new
    @client = OpenAiClient.new
  end

  def add(data)
    raise NotImplementedError
  end

  def get_context(data, num = 5)
    raise NotImplementedError
  end

  def summarize_memory(memory, max_tokens: 2500)
    return @client.summarize_memory(memory) if get_tokens(memory) < max_tokens

    text_chunks = chunk(memory, max_tokens)
    text_chunks.map { |chunk| @client.get_summary(text: chunk) }
  end

  def summarize_text(text, max_tokens: 2500)
    return @client.get_summary(text: text) if get_tokens(text) < max_tokens

    text_chunks = chunk(text, max_tokens)
    text_chunks.map { |chunk| @client.get_summary(text: chunk) }
  end

  # private

  def get_tokens(string = nil, bias = 0)
    return nil if string.nil?

    encoding = Tiktoken.encoding_for_model('gpt-3.5-turbo')

    tokens = encoding.encode(string)
    tokens.to_h { |token| [token, bias.to_i] }.length
  end

  def create_ada_embedding(data)
    puts "Creating embedding for #{data}"
    if get_tokens(data) > 5000
      data = summarize_text(data, max_tokens: 4000)
      puts "Summarized data to #{data}"
    end
    vector = OpenAiClient.get_embeddings(data)
    embedding = vector['data']&.first&.dig('embedding')
    embedding.is_a?(Array) ? embedding : [embedding]
  end

  def chunk(string, size)
    string.unpack("a#{size}" * (string.size / size.to_f).ceil)
  end
end
