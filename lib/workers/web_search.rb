require 'google_search_results'
require_relative 'base_worker'

class WebSearchWorker < BaseWorker
  def initialize(query)
    super
    @query = query
    # @summary = summarize_search
  end

  def results
    @spinner.auto_spin
    search = GoogleSearch.new(q: @query,
                              serp_api_key: '2ce4f8f301b18afbe18f642387c223d026c023ed740be146633ded9fdd54f8b2')
    results = search.get_hash
    results = results&.dig(:organic_results)&.first(5).to_json
    @spinner.stop
    results
  end

  def summary
    OpenAiClient.summarize_search(@results)
  end
end
