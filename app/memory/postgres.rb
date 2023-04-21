require 'pg'
require 'uuidtools'
require_relative 'base_memory'

class PostgresMemory < BaseMemory
  # need to create your database first
  def initialize
    super
    puts Config.memory_configuration

    @conn = PG.connect(Config.memory_configuration)
    @max_context_size = 4000
    create_table_if_not_exists

    # return unless @config.clear_database_on_start?

    # clear_table
  end

  def add(data)
    vector = create_ada_embedding(data)
    return nil unless vector.is_a? Array

    id = UUIDTools::UUID.random_create
    @conn.exec_params(
      'INSERT INTO memory (id, vector, data) VALUES ($1, $2, $3);',
      [id.to_s, to_pg_array(vector), data]
    )
  end

  def add_memory(memory)
    summarized = summarize_memory(memory)
    if summarized.is_a? Array
      summarized.each { |item| add(item) }
    else
      add(summarized)
    end
  end

  def get_context(data, num = 1)
    return nil if data.nil?

    vector = create_ada_embedding(data)

    all_vectors = vectors_from_memory
    all_vectors.sort_by! { |v| cosine_similarity([v[1]], [vector]) }.reverse!

    top_k_vectors = all_vectors.first(num)
    results_list = top_k_vectors.map { |item| item[2] }
    results_list.join("\n")
  end

  private

  def create_table_if_not_exists
    @conn.exec(<<~SQL)
      CREATE TABLE IF NOT EXISTS memory (
          id UUID PRIMARY KEY,
          vector float[] NOT NULL,
          data TEXT NOT NULL
      );
    SQL
  end

  def clear_table
    @conn.exec('DELETE FROM memory;')
  end

  def vectors_from_memory
    result = @conn.exec('SELECT id, vector, data FROM memory;')
    result.map do |row|
      [row['id'], row['vector'].gsub('{', '').gsub('}', '').split(',').map(&:to_f), row['data']]
    end
  end

  def to_pg_array(array)
    "{#{array.join(',')}}"
  end

  def cosine_similarity(array_one, array_two)
    unless array_one.is_a?(Array) && array_two.is_a?(Array) && array_one.size == array_two.size
      return nil
    end

    array_one.flatten!
    array_two.flatten!
    calculate_similarity_score(array_one, array_two)
  end

  def calculate_similarity_score(array_one, array_two)
    dot_product = array_one.zip(array_two).map { |v1i, v2i| v1i * v2i }.reduce(:+)
    a = array_one.map { |n| n**2 }.reduce(:+)
    b = array_two.map { |n| n**2 }.reduce(:+)

    dot_product / (Math.sqrt(a) * Math.sqrt(b))
  end
end
