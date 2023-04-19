require_relative 'base_service'
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'net/http'

module Services
  class WebScrapeService < BaseService
    def initialize(command: nil, args: {})
      super(command: command, args: args)

      @url = args[:url]
    end

    def available_commands
      %i[scrape_text]
    end

    def command_mapping
      {
        scrape_text: :scrape_text
      }
    end

    def scrape_text
      raise ArgumentError, 'You must provide a URL' if @url.nil?

      uri = URI.parse(@url)
      response = Net::HTTP.get_response(uri)

      raise "Failed to retrieve content from URL: #{@url}" unless response.code == '200'

      doc = Nokogiri::HTML(response.body)
      doc.xpath('//body//text()[not(parent::script)]').map(&:text).join('\n')
    end
  end
end
