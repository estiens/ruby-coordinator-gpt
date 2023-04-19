require_relative 'base_service'

module Services
  class FileService < BaseService
    FILE_PATH = "#{Dir.pwd}/workspace".freeze

    def initialize(command: nil, args: {})
      super(command: command, args: args)

      @path = args[:path]
      @text = args[:text]
      check_path
    end

    def available_commands
      %i[read_file write_file append_file list_directory create_directory]
    end

    def check_path
      raise ArgumentError, 'You must provide a path' if @path.nil?
      raise ArgumentError, 'Path must not be outside the workspace' unless @path.start_with?(FILE_PATH)
    end

    def command_mapping
      {
        read: :read_file,
        read_file: :read_file,
        write: :write_file,
        write_file: :write_file,
        append_file: :append_file,
        list: :list_directory,
        list_directory: :list_directory,
        create_directory: :create_directory
      }
    end

    def delete_file
      File.delete(@path)
    end

    def read_file
      contents = nil
      File.open(@path, 'r') do |file|
        contents = file.read
      end
      contents
    end

    def write_file
      File.open(@path, 'w') do |file|
        file.write(@text)
      end
      "I have written the following to #{@path}: #{@text}"
    end

    def append_file
      File.open(@path, 'a') do |file|
        file.write(@text)
      end
      "I have appended the following to #{@path}: #{@text}"
    end

    def list_directory
      Dir.entries(@path)
    end
  end
end
