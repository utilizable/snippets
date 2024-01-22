FROM haproxy:latest
USER root
RUN apt-get update -y 
RUN apt-get -qq install -y  \
  sudo                      \
  supervisor                \
  rsync                     \
  ca-certificates           \
  gettext                   
USER 1001

COPY ./rootfs/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

EXPOSE 9001

#CMD ["/usr/bin/supervisord"]
