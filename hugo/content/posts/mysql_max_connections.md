---
title: "Mysql_max_connections"
date: 2020-04-29T20:58:12+01:00
draft: false
---

# Calculating the Max connections in MySQL programmatically in one pass

Sometimes you need to calculate the percentage of the maximum number of MySQL connections that are being used at any one time. Here is a piece of SQL that I'm using:

```

MariaDB [(none)]> SELECT VARIABLE_VALUE INTO @maxconn 
                  FROM INFORMATION_SCHEMA.GLOBAL_VARIABLES 
                  WHERE VARIABLE_NAME="MAX_CONNECTIONS"; 
                  SELECT COUNT(1) INTO @currentconn 
                  FROM INFORMATION_SCHEMA.PROCESSLIST; 
                  SELECT (@currentconn/@maxconn)*100 AS "% Connections used";

+--------------------+
| % Connections used |
+--------------------+
| 3.9735099337748347 |
+--------------------+
1 row in set (0.000 sec)

```
