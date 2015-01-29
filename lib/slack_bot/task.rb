module SlackBot
  class Task
    attr_reader :bots

    def initialize(bot_group)
      @bot_group = bot_group
      @tasks = []
    end

    def add_task(*args, &block)
      @tasks << [args, block]
    end

    def execute
      group = ThreadGroup.new
      @tasks.each do |args, task|
        group.add(Thread.start(@bot_group, task, *args) do |bot_group, task, *args|
          begin
            sleep 1
            task.call(bot_group, *args)
          rescue => e
            $stderr.puts e.message
            $stderr.puts e.backtrace
            $stderr.puts "retry"
            retry
          end
        end)
      end
    
      @bot_group.each do |bot|
        group.add(Thread.start(bot) do |bot|
          begin
            bot.start
          rescue => e
            $stderr.puts e.message
            $stderr.puts e.backtrace
            $stderr.puts "retry"
            sleep 10
            retry
          end
        end)
      end

      group.list.each do |th|
        th.join
      end
    end
  end
end
