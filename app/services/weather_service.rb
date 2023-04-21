require_relative 'base_service'
require 'httparty'

# TODO: refactor

module Services
  class WeatherService < BaseService
    API_KEY = 'your_api_key'
    BASE_URL = 'https://api.openweathermap.org/data/2.5/weather'

    def initialize(command: nil, args: {})
      super(command: command, args: args)

      @city = args[:city]
      @country = args[:country]
    end

    def available_commands
      %i[get_weather]
    end

    def command_mapping
      {
        get_weather: :get_weather
      }
    end

    def get_weather
      raise ArgumentError, 'You must provide a city' if @city.nil?
      raise ArgumentError, 'You must provide a country' if @country.nil?

      response = HTTParty.get("#{BASE_URL}?q=#{@city},#{@country}&appid=#{API_KEY}&units=metric")

      raise "Failed to retrieve weather data" unless response.code == 200

      weather_data = JSON.parse(response.body)
      "Current weather in #{@city}, #{@country}: #{weather_data['weather'][0]['description']}, temperature: #{weather_data['main']['temp']}°C"
    end
  end
end
