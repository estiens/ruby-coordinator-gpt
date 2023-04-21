require_relative 'spec_helper'
require 'yaml'

RSpec.describe Worker do
  let(:worker) { Worker.new(name: 'Test Worker', goal: 'Test Goal') }

  # move to prompt spec
  # describe '#prompt_start' do
  #   it 'loads the prompt_start from the YAML file' do
  #     yaml_data = YAML.load_file('prompts/worker_prompts.yml')
  #     expect(worker.prompt_start).to eq(yaml_data['prompt_start'])
  #   end
  # end

  # describe '#worker_prompt' do
  #   it 'loads the worker_prompt from the YAML file' do
  #     yaml_data = YAML.load_file('prompts/worker_prompts.yml')
  #     expect(worker.worker_prompt).to eq(yaml_data['worker_prompt'])
  #   end
  # end

  # describe '#worker_abilities' do
  #   it 'returns an array of worker abilities' do
  #     expect(worker.worker_abilities).to be_an(Array)
  #   end
  # end
end
