# genrandom

Test multiple ways of generating random numbers and see which one is fastest
Based on the suggestions on https://superuser.com/questions/792427/creating-a-large-file-of-random-bytes-quickly/792505

Note all these solutions are single-threaded.
Haven't yet found an easy way to generate randoms using all threads.
(Though of couse you can run these programs in parallel)

## Current result

Machine spec :

```
 OS: Ubuntu 20.04 focal
 Kernel: x86_64 Linux 5.4.0-31-generic
 CPU: AMD Ryzen 5 2600 Six-Core @ 12x 3.85GHz
 GPU: AMD/ATI Lexa PRO [Radeon 540/540X/550/550X / RX 540X/550/550X]
 RAM: 4455MiB / 24046MiB
```

Result:

```
Testing /dev/urandom
====================
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 14.1688 s, 75.8 MB/s

real	0m14.196s
user	0m0.000s
sys	0m14.191s
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 14.2162 s, 75.5 MB/s

real	0m14.242s
user	0m0.000s
sys	0m14.239s
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 14.2671 s, 75.3 MB/s

real	0m14.294s
user	0m0.000s
sys	0m14.290s

Testing openssl rand
====================

real	0m1.912s
user	0m1.828s
sys	0m0.084s

real	0m1.950s
user	0m1.905s
sys	0m0.044s

real	0m1.930s
user	0m1.865s
sys	0m0.064s

Testing openssl enc
===================
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 0.768787 s, 1.4 GB/s

real	0m0.795s
user	0m0.187s
sys	0m0.960s
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 0.81391 s, 1.3 GB/s

real	0m0.840s
user	0m0.208s
sys	0m0.971s
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 0.821516 s, 1.3 GB/s

real	0m0.849s
user	0m0.197s
sys	0m1.028s

Testing shred
=============

real	0m0.322s
user	0m0.307s
sys	0m0.009s

real	0m0.316s
user	0m0.309s
sys	0m0.005s

real	0m0.312s
user	0m0.310s
sys	0m0.000s
```
