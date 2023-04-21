require 'dotenv'

class Config

  def self.open_ai_api_key
    ENV['OPENAI_API_KEY']
  end

  def self.serp_api_key
    ENV.fetch('SERP_API_KEY', 'your_serp_api_key')
  end

  def self.workspace_path
    "#{__dir__}/workspace"
  end

  def self.base_model
    ENV.fetch('BASE_MODEL', 'gpt-4')
  end

  def self.fast_model
    ENV.fetch('FAST_MODEL', 'gpt-3.5-turbo')
  end

  def self.debug?
    ENV.fetch('DEBUG', 'false').downcase == 'true'
  end

  def self.clear_database_on_start?
    ENV.fetch('CLEAR_DB_ON_START', 'false').downcase == 'true'
  end

  def self.memory_configuration
    # return pinecone_config if memory_type == 'pinecone'

    return postgres_config if memory_type == 'postgres'

    raise 'Invalid memory type'
  end

  def self.postgres_config
    { host: ENV['POSTGRES_HOST'],
      dbname: ENV['DATABASE_NAME'],
      user: ENV['POSTGRES_USER'],
      password: ENV['POSTGRES_PASSWORD'] }
  end

  def self.memory_type
    ENV.fetch('MEMORY_TYPE', 'postgres').downcase
  end
end
