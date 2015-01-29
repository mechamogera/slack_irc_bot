# -*- encoding: utf-8 -*-
require 'http_proxy_from_env'
require 'aws-sdk'
require 'json'
require 'yaml'

lib_dir = File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
Dir.foreach(lib_dir) do |file|
  next if file == "." || file == ".."
  require File.join(lib_dir, file)
end

conf = YAML.load_file("conf/bot.yml")

group = SlackBot::BotGroup.new(notify_url: conf["slack"]["notify_url"],
                            notify_username: conf["slack"]["notify_username"])
conf["bot"]["count"].times do |i|
  group.add(conf["bot"]["server"], conf["bot"]["port"],
            nick: "#{conf["bot"]["name"]}#{i}",
            real: "#{conf["bot"]["name"]}#{i}",
            user: "#{conf["bot"]["name"]}#{i}",
            target_channels: conf["bot"]["channels"].map { |x| "##{x}" })
end

tasks = SlackBot::Task.new(group)
sqs = AWS::SQS.new(access_key_id: conf["aws"]["access_key_id"],
                   secret_access_key: conf["aws"]["secret_access_key"])
queue = sqs.queues.named(conf["aws"]["sqs"]["name"])

tasks.add_task(queue) do |bot_group, queue|
  queue.poll do |msg|
    data = JSON.parse(msg.body)
    if data["user_name"] != "slackbot"
      bot_group.talk("#{data["text"]}", user: "_#{data["user_name"]}")
    end
  end
end

tasks.execute
