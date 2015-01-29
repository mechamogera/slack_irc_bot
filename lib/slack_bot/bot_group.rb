require_relative 'client'

module SlackBot
  class BotGroup
    include Enumerable

    def initialize(opts)
      @bots = []
      @bot_info = Struct.new("BotInfo", :bot, :last_updated, :username)

      @notify_url = opts[:notify_url]
      @notify_username = opts[:notify_username]
    end

    def add(*args)
      bot = Client.new(*args)
      @bots << @bot_info.new(bot, Time.now, nil)
      if @bots.size == 1
        @bots.first.bot.privmsg_callback do |m|
          if @notify_url
            user = m.prefix.split("!")[0]
            unless @bots.find { |info| info.bot.nick == user }
              notifier = Slack::Notifier.new @notify_url
              notifier.ping(":#{user.chomp("_")}: #{m.params[1]}".force_encoding("UTF-8"),
                            username: @notify_username)
            end
          end
        end
      end
    end

    def each
      @bots.each do |bot_info|
        yield bot_info.bot
      end
    end

    def talk(msg, opts = {})
      bot_info = @bots.find { |info| info.username == opts[:user] }
      unless bot_info
        bot_info = @bots.min_by { |x| x.last_updated }
        bot_info.bot.change_nick(opts[:user])
        bot_info.username = opts[:user]
      end
      bot_info.last_updated = Time.now
      bot_info.bot.talk(msg)
    end
  end
end
