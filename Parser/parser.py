#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import sqlite3
import requests
import urllib
import re
from bs4 import BeautifulSoup

conn = sqlite3.connect('articles.db')
conn.text_factory = str
c = conn.cursor()

def open_db():
	c.execute('CREATE TABLE IF NOT EXISTS Articles (title TEXT, content TEXT)')
	
def insert_article(title, content):
	c.execute('INSERT INTO Articles (title, content) VALUES (?, ?)', (title, content))

def parse(html, title):
	soup = BeautifulSoup(html)
	html = soup.body.find(id='mw-content-text')
	t = open('contents/{0}.html'.format(title), 'w')
	t.write(html.renderContents())
	scr = html.find_all('script')
	for tag in scr:
		tag.decompose()
	#html.find("div", { "class" : "noprint"}).decompose()
	scr = html.find_all("span", "editsection")
	for tag in scr:
		tag.decompose()
	scr = html.find_all(class_=re.compile(".*metadata.*"))
	for tag in scr:
		tag.decompose()
	html = re.sub(r'href="/wiki/(.*)"', r'href="\1"',html.renderContents())
	return html

def main():
	open_db()
	f = open('zhwiki-latest-all-titles-in-ns0', 'r')
	count = 1
	for title in f:
		title = title.strip()
		print count, title
		headers = {'User-agent': 'Mozilla/5.0'}
		r = requests.get('http://zh.wikipedia.org/zh-cn/{0}'.format(urllib.quote(title)), headers=headers)
		html = parse(r.text, title)
		insert_article(title, html)
		count = count + 1
		if count >= 100:
			break

if __name__ == "__main__":
	try:
		main()
		conn.commit()
	except KeyboardInterrupt:
		conn.commit()
