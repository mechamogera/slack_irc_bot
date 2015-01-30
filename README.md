# slack_irc_bot
slackとIRCを以下のように中継するIRCボット
![slack_irc_bot構成](https://raw.githubusercontent.com/mechamogera/MyTips/master/images/slack_irc_bot/slack_irc_bot.png)

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
