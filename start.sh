#!/bin/bash

./docker_templates/init.sh

python3 manage.py sopds_scanner start --daemon
python3 manage.py sopds_server start

if [[ "$TELEGRAM_TOKEN" != "NONE" ]] ; then
    python3 manage.py sopds_util setconf SOPDS_TELEBOT_API_TOKEN "$TELEGRAM_TOKEN"
    python3 manage.py sopds_util setconf SOPDS_TELEBOT_AUTH False
    python3 manage.py sopds_telebot start --daemon
fi
