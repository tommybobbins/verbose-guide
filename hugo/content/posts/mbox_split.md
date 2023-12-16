+++
title = "Splitting an mbox into individual mails"
date = "2016-02-15"
author = ""
showFullContent = false
+++

# Splitting mbox into individual mails

Splitting an mbox format mailbox into individual mails using formail:

```
formail -ds sh -c 'cat > msg.${FILENO}' < incoming_mbox_fle
```
