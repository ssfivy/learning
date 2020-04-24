# openssl benchmarks

My intention was to research how to use openssl benchmarks using different engine backends.
However on my desktop machine I don't have a selection of different backends, so no dice here.

## Different hardware
I do have a Beaglebone Black, which does contain a hardware crypto engine, so I might try that next.
Note that this hardware is undocumented in the datasheets, contact your FAE to get details. Linux works though.

According to some google searches, none of the raspberry pis contain hw crypto engine.

Maybe I should set up yocto builds for this to experiment next.

## Unrelated
I also found this linked webpage useful for all other openssl commands: `https://www.madboa.com/geek/openssl/#benchmarking`
