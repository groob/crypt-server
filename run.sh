#!/bin/bash

ADMIN_PASS=${ADMIN_PASS:-}
cd /home/app/crypt
mkdir -p db
python manage.py syncdb --noinput
python manage.py migrate --noinput
python manage.py collectstatic --noinput

if [ ! -z "$ADMIN_PASS" ] ; then
  python manage.py update_admin_user --username=admin --password=$ADMIN_PASS
else
  python manage.py update_admin_user --username=admin --password=admin
fi
