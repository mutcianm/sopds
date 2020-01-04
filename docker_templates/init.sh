#!/bin/bash

# Init database template

TEMPLATE_DIR="docker_templates"
CONFIG_FILE="sopds/settings.py"

case "$DB_KIND" in
    "mariadb")
        sed -e \
            "s/\$$DB_NAME/$DB_NAME/g;s/\$DB_USER/$DB_USER/g;s/\$DB_PASS/$DB_PASS/g;s/\$DB_LOCATION/$DB_LOCATION/g" \
            ./$TEMPLATE_DIR/mariadb > ./$CONFIG_FILE
        ;;
    "postgres")
        sed -e \
            "s/\$$DB_NAME/$DB_NAME/g;s/\$DB_USER/$DB_USER/g;s/\$DB_PASS/$DB_PASS/g;s/\$DB_LOCATION/$DB_LOCATION/g" \
            ./$TEMPLATE_DIR/postgres > ./$CONFIG_FILE
        ;;
    "sqlite")
        cp ./$TEMPLATE_DIR/sqlite ./$CONFIG_FILE
        ;;
esac

python3 manage.py migrate
python3 manage.py sopds_util clear
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', '', 'admin')" | python3 manage.py shell
python3 manage.py sopds_util setconf SOPDS_ROOT_LIB "library/"
python3 manage.py sopds_util setconf SOPDS_LANGUAGE "$SOPDS_LANG"
python3 manage.py sopds_util setconf SOPDS_FB2TOEPUB "convert/fb2converter/fb2epub"
python3 manage.py sopds_util setconf SOPDS_FB2TOMOBI "convert/fb2converter/fb2mobi"
