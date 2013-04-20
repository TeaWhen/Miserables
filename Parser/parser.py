#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import sqlite3
import requests
import urllib
import re
import os
import os.path
from bs4 import BeautifulSoup
import zlib
from threading import Thread
from Queue import Queue
import time
import random

THREAD_NUMBER = 5

def open_db(cursor):
	cursor.execute('CREATE TABLE IF NOT EXISTS Articles (title TEXT, content BLOB)')
	
def parse(html):
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
		try:
			tag.decompose()
		except:
			continue

	# delete a's rel and title attribute
	tags = html.find_all('a')
	for tag in tags:
		if 'rel' in tag.attrs:
			del tag['rel']
		if 'title' in tag.attrs:
			del tag['title']
		
	# delete id="noteTA"'s div
	tags = html.find_all('div', id='noteTA')
	for tag in tags:
		tag.decompose()

	# delete class="image"'s a
	tags = html.find_all('a', 'image')
	for tag in tags:
		tag.decompose()
		
	# delete class="navbox"'s table
	tags = html.find_all('table', 'navbox')
	for tag in tags:
		tag.decompose()

	# delete class="noprint"'s everything
	tags = html.find_all(class_=re.compile(".*noprint.*"))
	for tag in tags:
		tag.decompose()

	# delete class="noprint"'s everything
	tags = html.find_all("a", "new")
	for tag in tags:
		tag.unwrap()

	html = html.renderContents()
	html = html.replace('\n', '')
	urls = re.findall('href=\"(/wiki/.*?)\"', html)
	for item in urls:
		html = html.replace(item, urllib.unquote(item.replace('/wiki/', '')))
	html = re.sub(r'<!--.+?-->', '', html, 0, re.DOTALL)
	return html

def run():
	while True:
		time.sleep(random.random())
		
		item = q.get()
		title = item[1]

		print item[0], title

		headers = {'User-agent': 'Mozilla/5.0'}
		r = requests.get('http://zh.wikipedia.org/w/index.php?title={0}&variant=zh-cn&redirect=no'.format(urllib.quote(title)), headers=headers)
		html = parse(r.text)

		# output HTML file for debug
		# output_dir = os.path.join(os.path.dirname(__file__), 'contents')
		# if not os.path.exists(output_dir):
		# 	os.makedirs(output_dir)
		# with open(os.path.join(output_dir, title.replace('/', '-') + '.html'), 'w') as html_file:
		# 	html_file.write(html)

		result.put([title, html])
		q.task_done()

def dba():
	conn = sqlite3.connect('articles.db')
	conn.text_factory = str
	cursor = conn.cursor()
	while True:
		item = result.get()
		title, content = item[0], item[1]
		compressed = zlib.compress(content)
		cursor.execute('INSERT INTO Articles (title, content) VALUES (?, ?)', (title, sqlite3.Binary(compressed)))
		result.task_done()
		conn.commit()
	conn.close()

result = Queue()
q = Queue()

def main():
	conn = sqlite3.connect('articles.db')
	conn.text_factory = str
	cursor = conn.cursor()
	
	open_db(cursor)

	f = open('zhwiki-latest-all-titles-in-ns0', 'r')
	res = cursor.execute('SELECT title FROM Articles')
	titles = [title[0] for title in res.fetchall()]

	conn.close()

	t = Thread(target=dba)
	t.start()

	for i in range(THREAD_NUMBER):
		t = Thread(target=run)
		t.start()

	counter = 0
	for title in f:
		title = title.strip()
		counter += 1
		if title not in titles:
			q.put([counter, title])
	
	conn.commit()

if __name__ == "__main__":
	main()
