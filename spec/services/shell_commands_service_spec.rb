require_relative '../spec_helper.rb'

RSpec.describe Services::ShellCommandService do
  subject { described_class.new(command: command, args: args) }

  describe '#run' do
    context 'when command is run_shell_command' do
      let(:command) { :run_shell_command }

      context 'when shell_command is provided' do
        let(:args) { { shell_command: 'ls' } }

        it 'runs the shell command' do
          expect(subject.run).to eq(`ls 2>&1`)
        end
      end

      context 'when shell_command is not provided' do
        let(:args) { {} }

        # it 'raises an ArgumentError' do
        #   expect { subject.run }.to raise_error(ArgumentError, "The proper syntax is command: run_shell_command, arguments: shell_command='ls'")
        # end
      end

      context 'when shell_command is disallowed' do
        let(:args) { { shell_command: 'rm -rf /' } }

        # it 'raises an ArgumentError' do
        #   expect { subject.run }.to raise_error(ArgumentError, 'This shell command is not allowed')
        # end
      end
    end

    context 'when command is not run_shell_command' do
      let(:command) { :invalid_command }
      let(:args) { {} }

      it 'returns an invalid command message' do
        expect(subject.run).to eq("Invalid command, the commands I have are #{subject.command_mapping}")
      end
    end
  end
end
