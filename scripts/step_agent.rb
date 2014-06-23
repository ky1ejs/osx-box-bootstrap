# Splits the arguments into (strict) base64 chunks
# Decodes all the chunks and exports them to environment variables
# Calls last parameter for execution

#
# Example
# ruby step_agent.rb aGVsbG89IndvcmxkIg==,ZGlyPSIkSE9NRSI= fi9zdGVwX2xpYnJhcnkvc3RlcC5zaA==
#
# It will produce the following script
#
# export hello=world
# export dir=$HOME
# ~/step_library/step.sh
#

require 'base64'

args = ARGV
begin
  @step_path = File.expand_path(Base64.strict_decode64(args.pop))
  raise FileNotFoundException.new("File not Found") unless File.exists?(@step_path)
rescue
  puts "Error: No step file found at path #{@step_path}"
  exit 1
end

File.delete('.concrete_step_inputs') if File.exists?('.concrete_step_inputs')

args.each do |arg|
  arg.split(",").each do |env_var|
    key, value = env_var.split(".")

    if key
      key=Base64.strict_decode64(key)
    else
      key=nil
    end

    if value
      value=Base64.strict_decode64(value)
    else
      value=nil
    end

    if key and value
      if key == '__INPUT_FILE__'
        # write the value to a file, and store the file's path as value, in the Environment
        tmp_folder_pth = File.join(Dir.home, 'concrete/tmp')
        system "mkdir -p \"#{tmp_folder_pth}\""
        step_input_store_file_path = "#{tmp_folder_pth}/step_input_store"
        puts " (i) Value will be saved into the input_store file: #{step_input_store_file_path}"
        File.open(step_input_store_file_path, 'w') { |f| f.write(value) }
        value = step_input_store_file_path
      end

      puts "$ export #{key}=\"#{value}\""
      File.open('.concrete_step_inputs', 'a') { |f| f.write("export #{key}=\"#{value}\" ") }

      saved_value = `source .concrete_step_inputs 2> /dev/null && echo $#{key}`.chomp
      ENV[key] = saved_value unless saved_value.empty?
    else
      puts "[i] Key or Value is missing - won't add it to the environment (#{key} = #{value})"
    end
  end
end

`chmod +x "#{@step_path}"`
Dir.chdir(File.dirname(@step_path)) do
  system @step_path
  @return_code = $?.exitstatus
end

exit @return_code