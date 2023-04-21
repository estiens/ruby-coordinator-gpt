module Services
  class EmailService < BaseService
    def initialize(command: nil, args: {})
      super(command: command, args: args)

      @to = args[:to]
      @subject = args[:subject]
      @body = args[:body]
    end

    def available_commands
      %i[send_email]
    end

    def command_mapping
      {
        send_email: :send_email
      }
    end

    def send_email
      raise ArgumentError, 'You must provide a recipient email address' if @to.nil?
      raise ArgumentError, 'You must provide a subject' if @subject.nil?
      raise ArgumentError, 'You must provide a body' if @body.nil?

      mail = Mail.new do
        from    'your@email.com'
        to      @to
        subject @subject
      end
      mail['body'] = @body
      deliver_mail(email: mail)
    end

    def deliver_mail(email:, delivery_method: :file)
      return unless delivery_method == :file

      email_text = email.to_s
      path = "#{FileService::FILE_PATH}/emails"
      FileService.new(command: :create_directory, args: { path: path }).run
      FileService.new(command: :write_file,
                      args: { path: "#{path}/#{@subject}.txt", text: email }).run
      "I have saved the following email to #{path}/#{@subject}.txt: #{email_text}"
    end
  end
end
