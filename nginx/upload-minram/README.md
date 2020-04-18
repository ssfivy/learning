# nginx upload-minram

This is experimentation to figure out the way to upload big files (100MB to 1GB) to the disk in a server without consuming that much RAM or temporary files on disk.

## Goal
- Upload say, 300MB file to a server
- File is meant to be written to disk
- RAM usage should not go above, say, 100MB, and must always be smaller than the full file
- nginx used for HTTPS termination
- additional backend service may be used (nginx only doing reverse proxying)

Some factors that might affect things:

- Network speed slower / faster than disk speed
- Transfer-encoding:chunked may / may not be used

## Initial ideas
- Need investigation on how to easily measure RAM usage of a process during tests.
- Any python backend is probably out: python wsgi does not support chunked transfer encoding, irregardless of library
- go net/http might be interesting to try
- nginx upload module does not support chunked: https://github.com/fdintino/nginx-upload-module/issues/62
- These stackoverflow answers indicate reverse proxying won't consume much resources:
    - https://serverfault.com/questions/624897/getting-a-chunked-request-through-nginx
    - https://serverfault.com/questions/159313/enabling-nginx-chunked-transfer-encoding

Memory measurement techniques:
- https://stackoverflow.com/questions/774556/peak-memory-usage-of-a-linux-unix-process
- https://unix.stackexchange.com/questions/77370/how-to-measure-on-linux-the-peak-memory-of-an-application-after-has-ended
- https://serverfault.com/questions/387268/linux-cpu-usage-and-process-execution-history

Since we are simply interested in whether the uploaded file is cached in RAM, the simpler methods should be okay ( time -v or syrupy  https://github.com/jeetsukumaran/Syrupy )
