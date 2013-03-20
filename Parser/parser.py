# -*- coding: UTF-8 -*-

import sqlite3
import requests
from bs4 import BeautifulSoup

conn = sqlite3.connect('articles.db')
conn.text_factory = str
c = conn.cursor()

def open_db():
	c.execute('CREATE TABLE IF NOT EXISTS Articles (title TEXT, content TEXT)')
	
def insert_article(title, content):
	print title
	c.execute('INSERT INTO Articles (title, content) VALUES (?, ?)', (title, content))

def parse(html):
	soup = BeautifulSoup(html)
	html = soup.body.find(id='mw-content-text')
	scr = html.find_all('script')
	for tag in scr:
		tag.decompose()
	#html.find("div", { "class" : "noprint"}).decompose()
	scr = html.find_all("span", { "class" : "editsection"})
	for tag in scr:
		tag.decompose()
	return html.renderContents()

def main():
	open_db()
	f = open('zhwiki-latest-all-titles-in-ns0', 'r')
	count = 1
	for title in f:
		headers = {'User-agent': 'Mozilla/5.0'}
		r = requests.get('http://zh.wikipedia.org/zh-cn/{0}'.format(title[:-1]), headers=headers)
		raw_html = r.text
		html = parse(raw_html)
		insert_article(title[:-1], html)
		count = count + 1
		if count >= 100:
			break

if __name__ == "__main__":
	try:
		main()
	except KeyboardInterrupt:
		conn.commit()
