# Polarion Canteen Bot

Slack bot for Polarion Canteen that sends (and translates) a daily menu from Polarion Prague Office canteen to the [slack](https://slack.com/) channel

Screenshot
![Screenshot](https://raw.githubusercontent.com/Polarion/polarion-canteen-bot/master/doc/screen.png)

You will need following:

1. [Slack Webhook URL](https://my.slack.com/services/new/incoming-webhook/) 
2. [Microsoft Translator API](https://www.microsoft.com/en-us/translator/getstarted.aspx) app ID and Secret
3. [Eurest menu](https://restaurace.eurest.cz/Pages/Client/Restaurant/MenuCard.aspx) access

How to clone the project:
```bash
git clone https://github.com/Polarion/polarion-canteen-bot.git
cd polarion-canteen-bot
cp .env_template .env
bundle install
```

modify the `.env` file according your credentials and then run (or schedule in cron)
```
ruby main.rb
```
