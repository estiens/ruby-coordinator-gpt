describe Services::FileService do
  let(:path) { "#{Config.workspace_path}/test_file.txt" }
  let(:text) { 'sample text'}
  let(:command) { :read_file }
  let(:file_service) { Services::FileService.new(command: command, args: { path:, text: }) }

  context 'when path is valid' do
    before(:each) do
      FileUtils.touch(path)
    end

    after do
      File.delete(path) if File.exist?(path)
    end

    describe '#read_file' do\
      it 'should read file content' do
        expect(File).to receive(:open).with(path, 'r').and_call_original
        result = file_service.run
        expect(result).to_not be_nil
      end
    end

    describe '#write_file' do
      let(:command) { :write_file }

      it 'should write content to file' do
        expect(File).to receive(:open).with(path, 'a+').and_call_original
        result = file_service.run
        expect(result).to include(text)
      end
    end

    describe '#append_file' do
      let(:command) { :append_file }
      let(:text) { 'Sample text.' }

      it 'should append content to file' do
        expect(File).to receive(:open).with(path, 'a').and_call_original
        result = file_service.run
        expect(result).to include(text)
      end
    end
  end

  context 'when path is invalid' do
    let(:path) { '/root/test_file.txt' }

    it 'should raise ArgumentError' do
        expect(file_service.run).to include 'There was an error'
    end
  end

  describe '#check_path' do
    context 'when path is nil' do
      let(:args) { { path: nil } }

      it 'should raise ArgumentError' do
        expect(file_service.run).to include 'There was an error'
      end
    end

    context 'when path is outside the workspace' do
      let(:path) { '/root/test_file.txt' }
      let(:args) { { path: path } }

      it 'should raise ArgumentError' do
        expect(file_service.run).to include 'There was an error'
      end
    end
  end
end
