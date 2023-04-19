require 'spec_helper'
require_relative '../../lib/services/web_scrape_service'
require 'nokogiri'

RSpec.describe Services::WebScrapeService do
  describe '#scrape_text' do
    let(:url) { 'http://example.com' }
    let(:html) { "<html><head></head><body><p>Hello, world!</p><script>console.log('test');</script></body></html>" }
    let(:expected_text) { 'Hello, world!' }

    before do
      allow(Net::HTTP).to receive(:get_response).and_return(OpenStruct.new(code: '200', body: html))
    end

    it 'scrapes the text from the given URL' do
      service = Services::WebScrapeService.new(command: :scrape_text, args: { url: url })
      result = service.run
      expect(result).to eq(expected_text)
    end

    it 'raises an error if no URL is provided' do
      service = Services::WebScrapeService.new(command: :scrape_text, args: { url: nil })
      result = service.run
      expect(result).to include 'ArgumentError'
    end
  end
end
