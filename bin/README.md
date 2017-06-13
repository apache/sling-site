# Attention

Since the commits of a full jbake binary are very large you should split the contents of the lib-subfolder into multiple commits.

Before that call:
``` 
$ git config --global http.postBuffer 524288000 
``` 

In case of errors you may get the following behaviour, push takes a couple of minutes and fails:
``` 
$ git push
Zähle Objekte: 33, Fertig.
Delta compression using up to 4 threads.
Komprimiere Objekte: 100% (32/32), Fertig.
Schreibe Objekte: 100% (33/33), 8.05 MiB | 0 bytes/s, Fertig.
Total 33 (delta 10), reused 0 (delta 0)
error: RPC failed; HTTP 408 curl 22 The requested URL returned error: 408 Request Timeout
fatal: The remote end hung up unexpectedly
fatal: The remote end hung up unexpectedly
Everything up-to-date
``` 
