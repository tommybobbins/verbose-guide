#!/usr/bin/python
import subprocess,os
import datetime
import re
import struct, socket
now = datetime.datetime.now()

print "Content-Type: text/plain\n\n"
santa_list = "Nice"

if os.environ['REMOTE_ADDR']:
    santa_ip=os.environ['REMOTE_ADDR']
else:
    santa_list = "Naughty"
    santa_ip = "0.0.0.1"

ip2int = lambda ipstr: struct.unpack('!I', socket.inet_aton(ipstr))[0]
santa_number_ip = ip2int(santa_ip)
#print santa_number_ip

if santa_ip == "46.37.172.87":
   santa_list="UKFast IP: {} is on the Nice list".format(santa_ip)
elif santa_ip == "80.244.179.100":
   santa_list="UKFast Archway is probably on the Nice list"
elif santa_ip == "185.197.63.204":
   santa_list="MAN4, you are  definitely on the Nice list"
elif santa_ip == "46.37.163.184":
   santa_list="MAN5, you are definitely on the Nice list"
elif santa_ip == "46.37.163.116":
   santa_list="Guardhouse, you are definitely on the Nice list"
elif re.search(r"80.244.186.14", santa_ip):
   santa_list="Stu. You are definitely on the Nice list"
elif re.search(r"81.111.142.101", santa_ip):
   santa_list="Stu. You are definitely on the Nice list"
elif santa_ip == "178.238.134.196":
   santa_list="Rohan, you are on the Nice list"
elif (santa_number_ip % 2) == 0:
   #Even numbered IP
   santa_list="Your IP {} is on the Nice list".format(santa_ip)
elif (santa_number_ip % 2) > 0:
   #Odd numbered IP
   santa_list="Your IP {} may be on the Naughty list".format(santa_ip)
else:
   santa_list="Your IP {} is on the Naughty list".format(santa_ip)

cmd = "echo Ho. Ho. Ho. {} Happy Christmas {} | boxes -d santa".format(now.year,santa_list)
#print cmd
status = os.popen(cmd).read()
print status

#for param in os.environ.keys():
#  print "<b>%20s</b>: %s</br>\n" % (param,os.environ[param])

