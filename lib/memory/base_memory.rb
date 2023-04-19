require 'tiktoken_ruby'
require_relative '../open_ai_client'

class BaseMemory
  def initialize
    @config = Config.new
  end

  def add(data)
    raise NotImplementedError
  end

  def get_context(data, num = 5)
    raise NotImplementedError
  end

  def summarize_memory(memory, max_tokens: 2000)
    return memory if memory.length < max_tokens

    text_chunks = chunk(memory, max_tokens)
    OpenAiClient.summarize_memory(text_chunks)
  end

  def summarize_text(text, max_tokens: 2500)
    return OpenAiClient.get_summary(text:) if text.length < max_tokens

    text_chunks = chunk(text, max_tokens)
    text_chunks.map { |chunk| OpenAiClient.get_summary(text: chunk) }
  end

  # private

  def get_tokens(string = nil, bias = 0)
    return nil if string.nil?

    encoding = Tiktoken.encoding_for_model('gpt-3.5-turbo')

    tokens = encoding.encode(string)
    tokens.map do |token|
      [token, bias.to_i]
    end.to_h
  end

  def create_ada_embedding(data)
    vector = OpenAiClient.get_embeddings(data)
    vector['data'].first&.dig('embedding')
  end

  def chunk(string, size)
    string.unpack("a#{size}" * (string.size / size.to_f).ceil)
  end
end
