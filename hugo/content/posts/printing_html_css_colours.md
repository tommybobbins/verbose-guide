---
title: "Printing_html_css_colours"
date: 2011-06-05T19:55:56+01:00
draft: false
---

Printing out HTML/CSS Colours


I was trawling around websites trying to get an idea for colour schemes. They all appear to be infested with banner ads and anti-virus peddlers.



For people who like to roll their own, here is a Python script to dump out the hex codes for the first 16**3 colours:




```
#!/usr/bin/python
#Script to dump out all basic web colours in a table

hex_colours=['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F']
counter=1;
print """ 
<html>
<head></head>
<body>
<table>

"""

print '<tr>'
for alpha1 in hex_colours:
	for alpha2 in hex_colours:
		alpha12=alpha1+alpha2
		for alpha3 in hex_colours:
			alpha123=alpha12+alpha3
			print '<td style=\"background-color:#%s ;\">%s</td>' % (alpha123,alpha123)
#Every 20 cells, we want to change row
			if counter%17==0  :
					print '</tr>\n<tr>'
			counter += 1
print '</tr>'
print """
</body>
</html>
"""

```
