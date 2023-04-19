require_relative 'base_worker'

class ExecuteShellCommandWorker < BaseWorker
  def initialize(query)
    super
    @query = query
  end

  def results
    @spinner.auto_spin

    @spinner.stop
    results
  end

  def summary
    OpenAiClient.summarize_search(@results)
  end
end
