---
title: "Finding the longest running cron jobs in Magento"
date: 2020-04-07T20:38:43+01:00
draft: false
---

Finding the longest running cron jobs in Magento using MySQL:

```
SELECT job_code,scheduled_at,executed_at,finished_at,TIMEDIFF(finished_at,executed_at) AS timediff FROM cron_schedule ORDER BY timediff DESC LIMIT 20;
```
