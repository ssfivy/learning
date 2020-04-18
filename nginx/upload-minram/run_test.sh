#!/bin/bash

set -xe

# syrupy is python2 but oh well it works

THIS_SCRIPT_DIR=$(dirname $(realpath -s $0))
TOPDIR=$THIS_SCRIPT_DIR/lrn_build
BUILDDIR=$TOPDIR/build
PREFIXDIR_NGINX=$TOPDIR/prefix_nginx
RUNTIMEDIR_PROFILER=$TOPDIR/profiler

#./syrupy.py python3 ./test.py

NGINX_BINARY=$PREFIXDIR_NGINX/nginx.bin

# must matcn nginx.conf
mkdir -p $PREFIXDIR_NGINX/uploads

pushd $RUNTIMEDIR_PROFILER

# looks like nginx will laways to try opening default error log location before reading config.
# so you will see nginx: [alert] could not open error log file: open() "/var/log/nginx/error.log" failed (13: Permission denied)
# this seems normal and unavoidable :(
echo "Validating nginx config"
$NGINX_BINARY -c $THIS_SCRIPT_DIR/dut/nginx.conf -t

# nginx starts and then forks, and this confuses syrupy
# so we gotta match by pid or process name
# pid will be very tricky, so we match process name and assume the system nginx isn't being used
echo "Starting nginx"
$NGINX_BINARY -c $THIS_SCRIPT_DIR/dut/nginx.conf &
echo "Delay until startup finished"
sleep 1

#echo "Starting syrupy"
#$THIS_SCRIPT_DIR/syrupy.py --poll-command="$NGINX_BINARY" &


# RUN TEST HERE
sleep 10

echo "Stop nginx master process"
$NGINX_BINARY -c $THIS_SCRIPT_DIR/dut/nginx.conf  -s stop

popd
