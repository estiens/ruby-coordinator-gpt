require 'dotenv/load'
require_relative 'config'

Dir[File.join(__dir__, 'memory', '*.rb')].sort.each { |file| require file }
Dir[File.join(__dir__, 'workers', '*.rb')].sort.each { |file| require file }
Dir[File.join(__dir__, 'services', '*.rb')].sort.each { |file| require file }
Dir[File.join(__dir__, 'prompts', '*.rb')].sort.each { |file| require file }
