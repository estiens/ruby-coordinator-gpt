require_relative '../open_ai_client'

module Services
  class AskRobotService
    def initialize(command: ask, args: {})
      @question = args[:question] || args[:query]
    end

    def available_commands
      %i[send_email]
    end

    def command_mapping
      {
        ask: :ask_question,
        ask_question: :ask_question
      }
    end

    def ask_question
      messages = [
        { role: 'user',
          content: 'You are a helpful AI assistant talking to an autonomous AI seeking help with completing a task. Be as explicit as possible.' },
        { role: 'user', content: @question }
      ]
      open_ai_client = OpenAiClient.new(messages: messages, model: 'gpt-3.5-turbo')
      open_ai_client.chat
    end
  end
end
