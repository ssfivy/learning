FROM phusion/baseimage

USER root

RUN rm -f /etc/service/sshd/down

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.

# Note: at the moment we do not run this because we are going to use the insecure key
#RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

ENV CHECK_AM_I_IN_CONTAINER YES

CMD ["/sbin/my_init", "--enable-insecure-key"]
