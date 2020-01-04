#!/bin/bash

./docker_templates/init.sh

python3 manage.py sopds_scanner start --daemon
python3 manage.py sopds_server start
