lib_dir = File.expand_path(File.join(File.dirname(__FILE__), 'slack_bot'))
Dir.foreach(lib_dir) do |file|
    next if file == "." || file == ".." 
      require File.join(lib_dir, file)
end
