#!/bin/bash

set -xe

# syrupy is python2 but oh well it works

THIS_SCRIPT_DIR=$(dirname $(realpath -s $0))
TOPDIR=$THIS_SCRIPT_DIR/lrn_build
BUILDDIR=$TOPDIR/build
PREFIXDIR_NGINX=$TOPDIR/prefix_nginx
RUNTIMEDIR_PROFILER=$TOPDIR/profiler

# must match setup_system.sh
NGINX_BINARY=$PREFIXDIR_NGINX/nginx.bin
NGINX_PIDFILE=${PREFIXDIR_NGINX}/nginx.pid

# must matcn nginx.conf
UPLOADS_DIR=$PREFIXDIR_NGINX/nginx-upload-minram
#UPLOADS_DIR=/media/archives/nginx-upload-minram
mkdir -p $UPLOADS_DIR

TEST_FILE_PATH=/run/user/$(id -u)/test_file_upload.bin
TEST_FILE_SIZE=200M

# Validate nginx config first: break early if we are misocnfigured
# looks like nginx will laways to try opening default error log location before reading config.
# so you will see nginx: [alert] could not open error log file: open() "/var/log/nginx/error.log" failed (13: Permission denied)
# this seems normal and unavoidable :(
echo "Validating nginx config"
$NGINX_BINARY -c $THIS_SCRIPT_DIR/dut/nginx.conf -t

# Generate test file in RAM so read speed from disk doesn't matter
echo "Generating test file"
rm -f $TEST_FILE_PATH
dd if=/dev/urandom iflag=fullblock of=$TEST_FILE_PATH count=1 bs=$TEST_FILE_SIZE



# nginx starts and then forks, and this confuses syrupy
# so we gotta match by pid or process name
# pid will be very tricky, so we match process name and assume the system nginx isn't being used
start_nginx() {
    DEVICE=$(findmnt -n -o SOURCE --target $UPLOADS_DIR)
    echo "Starting nginx"
    systemd-run --user \
        -p "Type=forking" \
        -p "PIDFile=$NGINX_PIDFILE" \
        -p "IOWriteBandwidthMax=$DEVICE 1M" \
        $NGINX_BINARY -c $THIS_SCRIPT_DIR/dut/nginx.conf &
    echo "Delay until startup finished"
    sleep 2
}

stop_nginx() {
    echo "Stop nginx"
    $NGINX_BINARY -c $THIS_SCRIPT_DIR/dut/nginx.conf  -s stop
}

start_profiler () {
    pushd $RUNTIMEDIR_PROFILER
    echo "Starting syrupy"
    $THIS_SCRIPT_DIR/syrupy.py --poll-command="$NGINX_BINARY" &
}
stop_profiler () {
    popd
}


# RUN TEST HERE
#####################


# UPLOAD MODULE TESTS
start_nginx
#start_profiler
curl -X POST \
  http://localhost:43010/backend_uploadmodule \
  -H 'cache-control: no-cache' \
  -F "filename=@${TEST_FILE_PATH}"

sleep 10
#stop_profiler
stop_nginx


#########################


echo "Cleaning test file"
rm -f $TEST_FILE_PATH
rm -rf $UPLOADS_DIR

#EOF
