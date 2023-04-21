class OpenAiMockClient
  def initialize(responses = {})
    @responses = responses
  end

  def chat(parameters:)
    model = parameters[:model]
    messages = parameters[:messages]
    temperature = parameters[:temperature]
    key = messages.map { |m| m['content'] }.join
    @responses[key] || { 'choices': [{ 'message': { 'content': 'No mock response found for this input.' } }] }
  end

  def set_mock_response(input, response)
    @responses[input] = response
  end

  def clear_mock_responses
    @responses.clear
  end

  # to figure out when to call to VCR responses to test functionality
  # without incurring API costs
  def save_responses_to_file(file_path)
    File.open(file_path, 'w') do |file|
      file.write(JSON.pretty_generate(@responses))
    end
  end

  def load_responses_from_file(file_path)
    if File.exist?(file_path)
      @responses = JSON.parse(File.read(file_path))
    else
      puts "File not found: #{file_path}"
    end
  end
end
