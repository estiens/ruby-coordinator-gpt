# require 'openai'
# require 'json'
require 'dotenv/load'
# # require 'colorize'
# require 'nokogiri'
# require 'open-uri'
# require 'pry'
# require 'tty-spinner'

require_relative 'memory/postgres'
require_relative 'config'

Dir[File.join(__dir__, 'services', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'workers', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'prompts', '*.rb')].each { |file| require file }
