require 'spec_helper'

RSpec.describe PromptBuilder, type: :model do
  describe '#worker_prompt' do
    let(:custom_prompts) { ['Custom prompt 1', 'Custom prompt 2'] }
    let(:summary) { 'Test summary' }
    let(:last_actions) { ['Action 1', 'Action 2'] }
    let(:prompt_builder) { PromptBuilder.new(custom_prompts: custom_prompts, summary: summary, last_actions: last_actions) }

    it 'includes custom prompts' do
      custom_prompts.each do |prompt|
        expect(prompt_builder.worker_prompt).to include(prompt)
      end
    end

    it 'includes summary' do
      expect(prompt_builder.worker_prompt).to include(summary)
    end

    it 'includes last actions' do
      expect(prompt_builder.worker_prompt).to include(last_actions.join(','))
    end
  end
end
