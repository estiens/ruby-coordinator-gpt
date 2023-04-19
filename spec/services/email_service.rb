require_relative '../spec_helper'

RSpec.describe Services::EmailService do
  describe '#run' do
    subject { described_class.new(command: command, args: args) }

    context 'when the command is :send_email' do
      let(:command) { :send_email }
      let(:args) { { to: 'recipient@example.com', subject: 'Test Subject', body: 'Test Body' } }

      before(:each) do
        @result = subject.run
      end

      it 'sends the email and returns the result' do
        expect(@result).to include('emails/Test Subject.txt')
      end

      context 'when the recipient email address is missing' do
        let(:args) { { subject: 'Test Subject', body: 'Test Body' } }

        it 'raises an ArgumentError' do
          expect(@result).to include 'ArgumentError'
        end
      end

      context 'when the subject is missing' do
        let(:args) { { to: 'recipient@example.com', body: 'Test Body' } }

        it 'raises an ArgumentError' do
          expect(@result).to include 'ArgumentError'
        end
      end

      context 'when the body is missing' do
        let(:args) { { to: 'recipient@example.com', subject: 'Test Subject' } }

        it 'raises an ArgumentError' do
          expect(@result).to include 'ArgumentError'
        end
      end
    end

    context 'when the command is invalid' do
      let(:command) { :invalid_command }
      let(:args) { {} }

      it 'returns an error message' do
        result = subject.run

        expect(result).to include("Invalid command")
        expect(result).to include(":send_email")
      end
    end
  end
end
