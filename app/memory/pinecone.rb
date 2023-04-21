# class PineconeMemory < Memory
#   def initialize
#     super
#     Pinecone.api_key = ENV['PINECONE_API_KEY']
#     Pinecone.environment = ENV['PINECONE_REGION']

#     unless Pinecone.list_indexes.include?('microgpt')
#       puts 'Creating Pinecone index...'
#       Pinecone.create_index('microgpt', dimension: 1536, metric: 'cosine', pod_type: 'p1')
#     end

#     @index = Pinecone::Index.new('microgpt')

#     @index.delete(delete_all: 'true') if %w[true 1 t y yes].include?(ENV['CLEAR_DB_ON_START'])
#   end

#   def add(data)
#     vector = create_ada_embedding(data)
#     id = UUIDTools::UUID.random_create

#     @index.upsert([{ id: id.to_s, vector:, metadata: { data: } }])
#   end

#   def get_context(data, _num = 5)
#     vector = create_ada_embedding(data)
#     results = @index.query
#   end
# end
