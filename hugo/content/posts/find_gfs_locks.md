---
title: "Find and mail GFS locks"
date: 2020-04-12T21:48:38+01:00
draft: false
---

Shell script to email when GFS locks are found in /var/log/messages. Ensure that you change the MAIL_TO and the MAIL_FROM variables before running the script

```
#!/bin/bash

HISTORICAL_OUTPUT=/tmp/gfs2_locks.old
CURRENT_OUTPUT=/tmp/gfs2_locks.new
CHECK_LOCKS_OUT=/tmp/check_locks.log
MAIL_TO=myemail@null.net
MAIL_FROM=root@servername
MAIL_SUBJECT="GFS locks exist on ${HOSTNAME}"

MATCHED_MESSAGE=$(/bin/grep "task gfs2"  /var/log/messages | /bin/grep "blocked for more than 120 seconds"  | /usr/bin/tail -1)
echo $MATCHED_MESSAGE >$CURRENT_OUTPUT

send_email()
{
#echo "Sending email here"
mailx -r $MAIL_FROM -s "${MAIL_SUBJECT}" $MAIL_TO <<EOF
$MATCHED_MESSAGE
EOF

}

```
