---
title:  "Assignment 3 updated"
date:   2014-11-23 15:25:00
---

I have added an HTTP option to assignment 3, since some people are having difficulty with
DNS.  Being a simple ASCII protocol, this option should be quite doable.

Also, I have simplified the DNS client considerably:
  * If the server returns multiple records, you need only display the first result returned.
  * You only need to support querying for an A record.
  * If you implement support for all the records previously listed, then you'll earn up to 30% in bonus marks.
