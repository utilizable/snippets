FROM nginx:latest

RUN apt-get -qq update -y
RUN apt-get -qq install -y  \
  sudo                      \
  supervisor                \
  rsync                     \
  ca-certificates           \
  gettext                   \
  php                       \
  php-cli                   \
  php-xml                   \
  php-zip                   \
  php-curl                  \
  php-gd                    \
  php-cgi                   \
  php-fpm                   \
  php-mysql                 \
  php-mbstring 2>/dev/null


RUN mkdir -p /run/php                 \
    && touch /run/php/php7.4-fpm.sock \
    && touch /run/php/php7.4-fpm.pid

RUN rm -rf /etc/nginx/conf.d

COPY ./nginx/rootfs /

WORKDIR /etc/nginx

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout cert.key -out cert.crt -subj "/C=/ST=/L=/O=/OU=/CN=localhost"

EXPOSE 9001

RUN usermod -a -G www-data nginx

CMD ["/usr/bin/supervisord"]
