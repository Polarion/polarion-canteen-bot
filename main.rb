#!/usr/bin/env ruby
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'mechanize'
require "awesome_print"
require "microsoft_translator"
require 'dotenv'
require "slack"

Dotenv.load  File.dirname(__FILE__).to_s + "/.env"

def get_title(index)
	case index
	when 0
		return "P I."
	when 1
		return "P II."
	when 2
		return "M"
	when 3
		return "VJ I."
	when 4
		return "VJ II."
	when 5
		return "SJ"
	when 6
		return "BJ"
	end
end

slack_client = Slack::Web::Client.new(token: ENV["SLACK_TOKEN"])
# translator = MicrosoftTranslator::Client.new(ENV["MS_TRANS_ID"], ENV["MS_TRANS_SECRET"])

client = Mechanize.new { |agent|
	agent.user_agent_alias = 'Mac Safari'
}

foods = []
client.get('https://restaurace.eurest.cz/Pages/Client/Restaurant/MenuCard.aspx') do |home_page|
	form = home_page.form_with(:id => 'aspnetForm')
	form['ctl00$ctl00$ContentMain$ContentBody$Login$UserName'] = ENV["EUREST_LOGIN"]
	form['ctl00$ctl00$ContentMain$ContentBody$Login$Password'] = ENV["EUREST_PASSWORD"]
	menu = form.submit form.button

	doc = Hpricot(menu.body)
	table = (doc/"#ctl00_ctl00_ContentMain_ContentBody_menu__dlMenuCardDays")
	row = (table/"tr").first
	items_list = (row/"#ctl00_ctl00_ContentMain_ContentBody_menu__dlMenuCardDays_ctl00__dlMenuCardClaims_ctl00__dlMenuCardItems")
	(items_list/"tr").each_with_index do |item,index|
		divs = (item/"div")
		title = get_title(index)
		food = divs[3].inner_html.force_encoding("UTF-8").strip.gsub(/\(A.*\)/,"").strip

		if ENV['TRANSLATE'] == "true"
			translated = translator.translate(food,"cs","en","text/html")
			foods << "#{title} - *#{food}* _(#{translated})_"
		else
			foods << "#{title} - *#{food}*"
		end
	end
end

text = "*Todays selection in canteen is:*\n\n"
attachment = []
foods.each_with_index do |item,index|
	if index > 1
		# it is a soup
		text += ":curry: #{item}\n"
	else
		#it is a meal
		text += ":stew: #{item}\n"
	end
end

if ENV['VOTING'] == "true"
	text += "\n"
	text += "What time are you planning on going:\n :one: 11:30 • :two: 11:45 • :three: 12:00 • :four: 12:15 • :five: 12:30 • :six: Later" 
	post = slack_client.chat_postMessage(channel: "#{ENV['BOT_CHANNEL']}", text: text, as_user: false, username: ENV["BOT_NAME"], icon_url: ENV["BOT_ICON"])
	slack_client.reactions_add(name: "one", timestamp: post["ts"], channel: post["channel"])
	slack_client.reactions_add(name: "two", timestamp: post["ts"], channel: post["channel"])
	slack_client.reactions_add(name: "three", timestamp: post["ts"], channel: post["channel"])
	slack_client.reactions_add(name: "four", timestamp: post["ts"], channel: post["channel"])
	slack_client.reactions_add(name: "five", timestamp: post["ts"], channel: post["channel"])
	slack_client.reactions_add(name: "six", timestamp: post["ts"], channel: post["channel"])
else
	post = slack_client.chat_postMessage(channel: "#{ENV['BOT_CHANNEL']}", text: text, as_user: false, username: ENV["BOT_NAME"], icon_url: ENV["BOT_ICON"])
end

