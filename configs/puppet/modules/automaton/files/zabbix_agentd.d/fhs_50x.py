#!/usr/bin/env python

import os
import re
import sys
import time

from datetime import datetime

interval = 60

curtime = int(time.time())
exittime = curtime-interval
errors = 0

def filerev(somefile, buffer=0x20000):
  somefile.seek(0, os.SEEK_END)
  size = somefile.tell()
  lines = ['']
  rem = size % buffer
  pos = max(0, (size // buffer - 1) * buffer)
  while pos >= 0:
    somefile.seek(pos, os.SEEK_SET)
    data = somefile.read(rem + buffer) + lines[0]
    rem = 0
    lines = re.findall('[^\n]*\n?', data)
    ix = len(lines) - 2
    while ix > 0:
      yield lines[ix]
      ix -= 1
    pos -= buffer
  else:
    yield lines[0]

with open(sys.argv[1], 'r') as f:
  for line in filerev(f):
    match = re.search('(?P<ipaddress>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) - - \[(?P<date>\d{2}\/\w{3}\/\d{4}:\d{2}:\d{2}:\d{2}) (\+|\-)\d{4}\] (?:(?:(?:GET|POST) )(?P<url>.+)(HTTP\/1\.1)) \"(?P<statuscode>\d{3})\"', line)
    if match:
        unixtime = int(time.mktime(datetime.strptime(match.group('date'), "%d/%b/%Y:%H:%M:%S").timetuple()))
        match2 = re.search(r"5\d\d", match.group('statuscode'))
        if match2:
            errors = errors+1
        if (unixtime < exittime):
            print errors
            exit()
