class MemoryHandler
  # trying string extraction
  def self.extract_data_from_response(response)
    thought_match = /THOUGHT:\s*(.*)\s*COMMAND/
    command_match = /COMMAND:\s*(.*)\s*ARG/
    arguments_match = /ARGUMENTS:\s*(.*)\s*REF/
    reflections_match = /REFLECTIONS:\s*(.*)\s*/

    hash = {}
    hash[:thought] = response.match(thought_match)&.[]1
    hash[:command] = response.match(command_match)&.[]1
    args_str = response.match(arguments_match)&.[]1
    unless args_str.nil?
      args = args_str.split(',').map do |arg|
        k, v = arg.strip.split('=')
        [k.to_sym, v]
      end.to_h
      hash[:arguments] = args
      hash[:argument_string] = args_str
    end
    hash[:reflections] = response.match(reflections_match)&.[]1
    hash
  end

  # for cleaning invalid JSON for JSON extraction
  def self.clean_and_balance_json_string(json_string)
    # Remove outer double quotes if they exist
    json_string = json_string[1..-2] if json_string.start_with?('\"') && json_string.end_with?('\"')

    # Escape single quotes instead of replacing them with double quotes
    json_string.gsub!("'", "\\'")

    # Correctly escape special characters in the value strings
    json_string = json_string.gsub(/:(\s*)"(.*?)(?<!\\)"/) do |_match|
      escaped_string = Regexp.last_match(2).gsub(/(?!\\)"/, '\\"').gsub(/\\(?=(?!")\\")/, '\\\\')
      ":#{Regexp.last_match(1)}\"#{escaped_string}\""
    end

    # Balance brackets
    opening_braces = json_string.scan('{').length
    closing_braces = json_string.scan('}').length
    (opening_braces - closing_braces).times { json_string << '}' }

    json_string
  end
end
