#!/usr/bin/python

import os

f = open('../current_catspray.txt','w')
print "Content-type: text/html\r\n\r\n";
f.write ('Content-type: text/html\r\n\r\n');
print "<font size=+1>Environment</font></br>";
f.write ('<font size=+1>Environment</font></br>');
for param in os.environ.keys():
  print "<b>%20s</b>: %s</br>\n" % (param,os.environ[param])
  f.write ('<b>%20s</b>: %s</br>\n' % (param,os.environ[param]));

f.close()
