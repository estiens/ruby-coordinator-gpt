module Services
  class FileService < BaseService
    def initialize(command: nil, args: {})
      super(command: command, args: args)

      @path = args[:path]
      @text = args[:text] || args[:content]
      check_path
    end

    def available_commands
      %i[read_file write_file append_file list_directory create_directory delete_file]
    end

    def check_path
      return 'You must provide a path' if @path.nil?

      @path.gsub!('./', "#{workspace_path}/")
      @path.gsub!('//', '/')
      @path.gsub!('/workspace/workspace', '/workspace')
      @path.gsub!('/worker_directory', '/worker_instructions')
      @path.gsub!('/workspace/worker_instructions', '/worker_instructions')
      # @path.gsub!('workspace', workspace_path)
      # @path = "#{workspace_path}/#{@path}" unless @path.start_with?(workspace_path)
      # @path.gsub!('//', '/')
      return if @path.start_with?(Config.app_directory) || @path.start_with?(workspace_path)

      "Path must not be outside the workspace - you gave me #{@path}"
    end

    def workspace_path
      Config.workspace_path
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
        list_dir: :list_directory,
        create_directory: :create_directory,
        delete_file: :delete_file
      }
    end

    def delete_file
      File.delete(@path) if File.exist?(@path_to_file)
    end

    def read_file
      @contents = nil
      File.open(@path, 'r') do |file|
        @contents = file.read
      end
      "You successfully read a file at #{@path}\nContents: #{@contents}"
    end

    def write_file
      return 'You must provide text to write with a :text argument' if @text.nil?

      File.open(@path, 'a+') do |file|
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

    def create_directory
      dirname = File.dirname(@path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      dirname
    end

    def list_directory
      Dir.entries(@path)
    end
  end
end
