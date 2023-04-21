require_relative 'base_memory'

# TODO: Test memory Commands
require 'uuidtools'
require_relative 'base_memory'

class MockMemory < BaseMemory
  def initialize
    super
    @memory = {}
  end

  def add(data)
    id = "#data_#{@memory.length + 1}"
    @memory[id] = data
  end

  def add_memory(memory)
    id = "#memory_#{@memory.length + 1}"
    @memory[id] = memory
  end

  def get_context(data, num = 1)
    "#{@memory.values.sample(num).join(",")}_#{data}"
  end
end
