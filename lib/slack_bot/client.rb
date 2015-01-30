require 'rubygems'
require 'net/irc'
require 'slack-notifier'
require 'timeout'

module SlackBot
  class Client < Net::IRC::Client
    MSG_MAX = 454
    NICK_MAX = 9

    attr_accessor :target_channels
    attr_accessor :not_notify_user_pattern
    attr_accessor :notify_url
    attr_accessor :notify_username
  
    def initialize(host, port, opts = [])
      @target_channels = opts[:target_channels]
      @not_notify_user_pattern = opts[:not_notify_user_pattern]
      @notify_url = opts[:notify_url]
      @notify_username = opts[:notify_username]
      @privmsg_callback = nil
      @first_nick = "a"
      super(host, port, opts)
    end

    def privmsg_callback(&block)
      @privmsg_callback = block
    end

    def talk(msg, channels = @target_channels)
      channels.each do |channel|
        if msg.class == Array
          msg.each { |m| talk_core(channel, m) }
        else
          talk_core(channel, msg)
        end
      end
    end

    def change_nick(nick)
      crr_nick = @prefix.nick
      post(NICK, nick)
      timeout(3) do
        while @prefix.nick == crr_nick
          sleep 1
        end
      end
    rescue Timeout::Error
    end

    def nick
      @prefix ? @prefix.nick : ""
    end

    def on_rpl_welcome(m)
      super
      @first_nick = m.params[0]
      @target_channels.each do |channel|
        post(JOIN, channel)
      end
    end

    def on_privmsg(m)
      super
      @privmsg_callback.call(m) if @privmsg_callback
    end

    def on_nick(m)
      if prefix && m.prefix && (m.prefix.split("!")[1] == prefix.split("!")[1])
        @prefix = Prefix.new([m.params[0], prefix.split("!")[1]].join("!"))
      end
    end

    def on_err_nicknameinuse(m)
      if m.params[1] != "________"
        change_nick("_#{m.params[1]}")
      elsif m.params[1] != @first_nick
        change_nick(@first_nick)
      end
    end

    def on_err_erroneusnickname(m)
      if m.params[1].size > NICK_MAX
        change_nick(m.params[1][0...NICK_MAX])
      elsif m.params[1] != @first_nick
        change_nick(@first_nick)
      end
    end

    def talk_core(channel, msg)
      if msg.bytesize <= MSG_MAX
        post(PRIVMSG, channel, msg.force_encoding("UTF-8"))
      else
        msgs = [""]
        len = 0
        msg.split(//).each do |c|
          len += c.bytesize
          if len > MSG_MAX
            len = c.bytesize
            msgs << c
          else
            msgs.last << c
          end
        end
        
        msgs.each do |msg|
          post(PRIVMSG, channel, msg.force_encoding("UTF-8"))
        end
      end
    end
  end
end

