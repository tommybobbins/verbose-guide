+++
title = "Printing multiple PDFs quickly to a postscript printer"
date = "2014-03-02"
author = ""
authorTwitter = "" #do not include @
cover = ""
tags = ["", ""]
keywords = ["", ""]
description = ""
showFullContent = false
+++

# Printing PDFs quickly from Linux onto a Postscript compatible printer

Printing large quantities of the same document from GNU/Linux quickly
When using a Postscript printer, it is much quicker to convert a PDF to a Postscript and then print natively:

```
tng@coalman $ sudo apt-get install poppler-utils
tng@coalman $ pdftops filename.pdf; lpr -# 26 filename.ps 
```

This converts the file filename.pdf to a postscript file filename.ps and then sends it to the default printer 26 times. This is an order of magnitude faster than print 26 copies from either Chrome or evince which rebuilt the print job into one 26 page blob using ghostscript and then send it to the printer.
