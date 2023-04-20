require_relative 'base_service'
require 'google_search_results'
#TODO: remove API KEY
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
                                serp_api_key: '2ce4f8f301b18afbe18f642387c223d026c023ed740be146633ded9fdd54f8b2')
      results = search.get_hash
      results = results&.dig(:organic_results)&.first(5).to_json
      results
    end
  end
end
