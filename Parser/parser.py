#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import sqlite3
import requests
import urllib
import re
import os
import os.path
from bs4 import BeautifulSoup
import pylzma

conn = sqlite3.connect('articles.db')
conn.text_factory = str
c = conn.cursor()

def open_db():
	c.execute('CREATE TABLE IF NOT EXISTS Articles (title TEXT, content BLOB)')
	
def insert_article(title, content):
	compressed = pylzma.compress(content)
	c.execute('INSERT INTO Articles (title, content) VALUES (?, ?)', (title, sqlite3.Binary(compressed)))

def parse(html, title):
	soup = BeautifulSoup(html)
	html = soup.body.find(id='mw-content-text')
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
	html = html.renderContents()
	urls = re.findall('href=\"(/wiki/.*?)\"', html)
	for item in urls:
		html = html.replace(item, urllib.unquote(item.replace('/wiki/', '')))
	return html

def main():
	open_db()
	f = open('zhwiki-latest-all-titles-in-ns0', 'r')
	count = 1
	for title in f:
		title = title.strip()
		print count, title
		headers = {'User-agent': 'Mozilla/5.0'}
		r = requests.get('http://zh.wikipedia.org/w/index.php?title={0}&variant=zh-cn&redirect=no'.format(urllib.quote(title)), headers=headers)
		html = parse(r.text, title)
		
		# output HTML file for debug
		output_dir = os.path.join(os.path.dirname(__file__), 'contents')
		if not os.path.exists(output_dir):
			os.makedirs(output_dir)
		with open(os.path.join(output_dir, title + '.html'), 'w') as html_file:
			html_file.write(html)

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
