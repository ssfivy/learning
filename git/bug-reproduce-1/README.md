# Git bug?

I found an issue where on my desktop:
- there are two SSD, one root and another scratch ssd
- scratch ssd is encrypted using mechanism that I forgot (probably whatever was setup using kde partitionmanager in ubuntu 18.04
- scratch ssd is mounted in root ssd
- git repository sits  in scratch ssd
- git config includes does not work on git respositories in the scratch ssd

I tried to reproduce using loopback mount but failed.

I updated to ubuntu 20.04 and the problem seems to go away.

Halting this effort - good learning though.
