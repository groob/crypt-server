# Crypt Server Dockerfile
FROM phusion/passenger-customizable:0.9.11
MAINTAINER Pepijn Bruienne bruienne@umich.edu

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV DOCKER_CRYPT_ADMINS Admin User,admin@test.com
# ENV DOCKER_CRYPT_ALLOWED
ENV DOCKER_CRYPT_TZ America/Detroit
ENV DOCKER_CRYPT_LANG en_US

CMD ["/sbin/my_init"]
RUN apt-get -y update
RUN /build/utilities.sh
# RUN /build/devheaders.sh
RUN /build/python.sh

RUN apt-get -y install python-setuptools libapache2-mod-wsgi && easy_install pip && \
    git clone https://github.com/grahamgilbert/Crypt-Server.git /home/app/crypt && \
    pip install -r /home/app/crypt/setup/requirements.txt && \
    rm -f /etc/service/nginx/down

# Generate initial_data.json with:
# python manage.py syncdb (manually enter sample admin user)
# python manage.py dumpdata --indent=2 auth > initial_data.json
ADD initial_data.json /home/app/crypt/
# Add a modified settings.py that imports setting_import which in turn grabs
# Docker env vars, this way we separate out the main settings and Docker vars
ADD settings.py /home/app/crypt/fvserver/
ADD settings_import.py /home/app/crypt/fvserver/
ADD crypt.conf /etc/nginx/sites-enabled/
ADD crypt-env.conf /etc/nginx/main.d/crypt-env.conf
ADD passenger_wsgi.py /home/app/crypt/
# ADD https://raw.githubusercontent.com/nginx/nginx/master/conf/uwsgi_params /home/app/crypt/

RUN cd /home/app/crypt/ && \
    python manage.py syncdb --noinput && \
    python manage.py migrate && \
    python manage.py collectstatic --noinput && \
    chown -R app:app /home/app/crypt && \
    mkdir /home/app/crypt/tmp && \
    chmod go+w /home/app/crypt/crypt.db
