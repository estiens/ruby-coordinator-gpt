require_relative 'base_service'
module Services
  class WebSearchService < BaseService
    def initialize(command: nil, args: {})
      super(command: command, args: args)

      @query = args[:query]
    end

    def available_commands
      %i[search]
    end

    def command_mapping
      {
        search: :search
      }
    end

    def search
      raise ArgumentError, 'You must provide a query' if @query.nil?

      search = GoogleSearch.new(q: @query,
                                serp_api_key: Config.serp_api_key,)
      results = search.get_hash
      results = results&.dig(:organic_results)&.first(5).to_json
      OpenAiClient.new.summarize_search(results)
    end
  end
end
