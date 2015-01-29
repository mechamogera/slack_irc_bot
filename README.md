# slack_irc_bot
slackとIRCを中継するIRCボット

# 使い方

* slackのIntegrationでAmazon SQSを設定する
* slackのIntegrationでIncomming WebHooksを設定する
* slack_irc_botを取得する

```
$ git clone https://github.com/mechamogera/slack_irc_bot.git
$ cd slack_irc_bot
```

* conf/bot.ymlを適切に編集する
* slack_irc_botを起動する

```
$ bundle install --path vendor/bundle
$ bundle exec ruby slack_bot_main.rb
```
