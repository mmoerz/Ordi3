#!/bin/bash

CBDIR=certbot
DOMAIN=ordimoerz.at

certbot certonly --manual --preferred-challenges http -d $DOMAIN -d www.$DOMAIN --agree-tos \
  --config-dir=$CBDIR --work-dir=$CBDIR/work --logs-dir=$CBDIR/log \
  --preferred-challenges dns-01 \
  --server https://acme-v02.api.letsencrypt.org/directory \
  --register-unsafely-without-email --rsa-key-size 4096
