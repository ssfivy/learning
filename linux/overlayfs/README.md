# Overlayfs

Experimenting with overlayfs and tmpfs.
Goal: See if we can make a complete tmpfs overlay for /etc so we can configure a read-only filesystem

## Learnings

- How to do things is in the shell script
- If file in lower is read-only, we can't just write to upper even though there is an overlay in place.
- once a file is deleted, there will be a mark in the upper directory (char device, size 0, uidgid root:root), this cannot be opened at all so `cat *` will fail.

## References
- https://jvns.ca/blog/2019/11/18/how-containers-work--overlayfs/
- https://www.kernel.org/doc/Documentation/filesystems/overlayfs.txt
- https://unix.stackexchange.com/questions/324515/linux-filesystem-overlay-what-is-workdir-used-for-overlayfs
- https://www.kernel.org/doc/Documentation/filesystems/tmpfs.txt
