# SYSTEM_PROMPT = "You are an autonomous agent who fulfills the user's objective."
# INSTRUCTIONS = %q{
# Carefully consider your next command.
# Use only non-interactive shell commands.
# When you have achieved the objective, respond ONLY with the plaintext OBJECTIVE ACHIEVED (no JSON)
# Otherwise, respond with a JSON-encoded dict containing one of the commands: execute_shell, read_file, web_search, web_scrape, or talk_to_user
# Important: Escape all occurrences of \\n in Ruby code with \\\\n
# {"thought": "[REASONING]", "cmd": "[COMMAND]", "arg": "[ARGUMENT]"}
# Examples:
# {"First, I will search for websites relevant to salami pizza.", "cmd": "web_search", "arg": "salami pizza"}
# {"I am going to scrape information about Apples.", "cmd": "web_scrape", "arg": "https://en.wikipedia.org/wiki/Apple"}
# {"Showing results to the user", "cmd": "talk_to_user", "arg": "[My results]. Did I achieve my objective?"}
# {"I need to ask the user for guidance", "cmd": "talk_to_user", "arg": "What is URL of Domino's Pizza API?"}
# IMPORTANT: ALWAYS RESPOND ONLY WITH THIS EXACT JSON FORMAT. DOUBLE-CHECK YOUR RESPONSE TO MAKE SURE IT CONTAINS VALID JSON. DO NOT INCLUDE ANY EXTRA TEXT WITH THE RESPONSE.}

# config = Config.new
# database = PostgresMemory.new
# debug = true

# # if ARGV.length != 1
# #   puts "Usage: microgpt.rb <objective>"
# #   exit
# # end

# objective = ARGV[0]
# max_memory_item_size = 200
# objective = 'Figure out the github page for all GPT agent programs. Write them to a CSV file.'
# thought = 'I awakened moments ago.'

# while true
#   context = database.get_context("#{objective}, #{thought}")

#   puts "CONTEXT:\n#{context}" if debug

#   spinner = TTY::Spinner.new
#   spinner.auto_spin

#   rs = OpenAiClient.client.chat(
#     parameters: {
#       model: 'gpt-4',
#       messages: [
#         { role: 'system', content: SYSTEM_PROMPT },
#         { role: 'user', content: "OBJECTIVE:#{objective}" },
#         { role: 'user', content: "CONTEXT:\n#{context}" },
#         { role: 'user', content: "INSTRUCTIONS:\n#{INSTRUCTIONS}" }
#       ],
#       temperature: 0.7
#     }
#   )

#   spinner.stop
#   response_text = rs['choices'][0]['message']['content']

#   puts "RAW RESPONSE:\n#{response_text}" if debug

#   if response_text == 'OBJECTIVE ACHIEVED'
#     puts 'Objective achieved.'
#     exit
#   end

#   begin
#     response = JSON.parse(response_text)
#     thought = response['thought']
#     command = response['cmd']
#     arg = response['arg']

#     mem = "Your thought: #{thought}\nYour command: #{command}\nCmd argument:\n#{arg}\nResult:\n"
#   rescue Exception => e
#     puts "Unable to parse response. Retrying...\n".colorize(:red)
#     next
#   end

#   if command == 'talk_to_user'
#     puts "MicroGPT: #{arg}".colorize(:cyan)
#     user_input = gets.chomp
#     memory.add("#{mem}The user responded with: #{user_input}.")
#     next
#   end

#   _arg = arg.length < 64 ? arg.gsub("\n", '\\n') : "#{arg[0...64]}...".gsub("\n", '\\n')
#   puts "MicroGPT: #{thought}\nCmd: #{command}, Arg: \"#{_arg}\"".colorize(:cyan)
#   print 'Press enter to perform this action or abort by typing feedback: '
#   user_input = gets.chomp

#   if user_input.length > 0
#     memory.add("#{mem}The user responded: #{user_input}. Take this comment into consideration.")
#     next
#   end
#   mem = "Your thought: #{thought}\n\nYour command: #{command}\nCmd argument: #{arg}\n\nResult:"
#   begin
#     if command == 'execute_shell'
#       result = `#{arg}`
#       database.add("#{mem}STDOUT:\n#{result}")
#     elsif command == 'web_search'
#       worker = WebSearchWorker.new(arg)
#       results = worker.results
#       database.add("#{mem}#{results}")
#       summary = worker.summary
#       database.add("#{mem}#{summary}")
#       # summary = database.summarize_memory("#{mem}#{worker.summary}")
#       # database.add("#{mem}#{summary}")
#     elsif command == 'web_scrape'
#       html = open(arg).read
#       response_text = Nokogiri::HTML(html).text
#       database.add("#{response_text}")
#       summary = OpenAiClient.summarize_text(response_text)
#       database.add("#{mem}#{summary}")
#     elsif command == 'read_file'
#       file_content = File.read(arg)
#       database.add("#{mem}#{file_content}")
#     end
#   rescue Exception => e
#     database.add("#{mem}The command returned an error:\n#{e}\nYou should fix the command.")
#   end
# end
