FROM python:3-alpine

VOLUME ["/library", "/sqlite-data"]
EXPOSE 8001

# valid options: mariadb postgres sqlite
ENV DB_KIND=sqlite \
 DB_NAME=sopds \
 DB_USER=sopds \
 DB_PASS=sopds \
 DB_LOCATION=localhost \
 SOPDS_LANG=ru-RU \
 TELEGRAM_TOKEN=NONE \
 INIT=false

RUN apk add --update \
    libc6-compat \
    tzdata tar p7zip build-base bash \
    mariadb-connector-c-dev \
    openssl-dev \
    libxml2-dev \
    libxslt-dev \
    libffi-dev \
    libc-dev \
    jpeg-dev \
    zlib-dev && \
    pip3 install mysqlclient

ADD . /
ADD https://github.com/rupor-github/fb2converter/releases/download/1.41/fb2c-linux.7z fb2c.7z
RUN pip3 install -r requirements.txt
RUN cd convert/fb2converter && 7z x -y /fb2c.7z

ENTRYPOINT ["./start.sh"]
