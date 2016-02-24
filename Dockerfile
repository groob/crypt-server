# Crypt Server Dockerfile
FROM ubuntu:14.04.1
MAINTAINER Graham Gilbert <graham@grahamgilbert.com>

# Basic env vars for apt and Passenger
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV TZ America/New_York
ENV APP_DIR /home/docker/crypt
# DOCKER_CRYPT_* env vars configure the following possible settings in Crypt's
# settings.py:
# DOCKER_CRYPT_ADMINS = A list of lists (tuples) of names and email addresses of authorized admins
# DOCKER_CRYPT_ALLOWED = A list of allowed hosts or IP addresses, defaults to *
# DOCKER_CRYPT_LANG = Preferred language
# DOCKER_CRYPT_TZ = Time zone to use for GUI and logging

# To define multiple admins: Some Name,some@where.com:Another One,another@host.net
ENV DOCKER_CRYPT_ADMINS Admin User,admin@test.com
# ENV DOCKER_CRYPT_ALLOWED myhost,1.2.3.4,anotherhost.fqdn.com
ENV DOCKER_CRYPT_LANG en_US
ENV DOCKER_CRYPT_TZ America/New_York

RUN apt-get update && \
    apt-get install -y libc-bin && \
    apt-get install -y software-properties-common && \
    apt-get -y update && \
    add-apt-repository -y ppa:nginx/stable && \
    apt-get -y install \
    git \
    python-setuptools \
    nginx \
    postgresql \
    postgresql-contrib \
    libpq-dev \
    python-dev \
    supervisor \
    nano \
    libffi-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN easy_install pip && \
    git clone https://github.com/grahamgilbert/crypt-server.git $APP_DIR && \
    pip install -r $APP_DIR/setup/requirements.txt && \
    pip install psycopg2==2.5.3 && \
    pip install gunicorn && \
    pip install setproctitle

ADD nginx/nginx-env.conf /etc/nginx/main.d/
ADD nginx/crypt.conf /etc/nginx/sites-enabled/crypt.conf
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD settings.py $APP_DIR/fvserver/
ADD settings_import.py $APP_DIR/fvserver/
ADD wsgi.py $APP_DIR/
ADD gunicorn_config.py $APP_DIR/
ADD django/management/ $APP_DIR/server/management/
ADD run.sh /run.sh
ADD supervisord.conf $APP_DIR/supervisord.conf

RUN update-rc.d -f postgresql remove && \
    update-rc.d -f nginx remove && \
    rm -f /etc/nginx/sites-enabled/default && \
    mkdir -p /home/app && \
    mkdir -p /home/backup && \
    ln -s $APP_DIR /home/app/crypt

EXPOSE 8000

VOLUME $APP_DIR/keyset

CMD ["/run.sh"]
