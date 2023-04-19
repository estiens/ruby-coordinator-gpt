class BaseWorker
  def self.available_services
    { web_search: WebSearchService, execute_shell_command: ExecuteShellCommandWorker }
  end

  attr_reader :results

  def initialize(_args)
    @spinner = TTY::Spinner.new('Processing', format: :pulse_2)
  end

  def results
    raise NotImplementedError
  end
end
