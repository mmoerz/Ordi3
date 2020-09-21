#!/bin/bash
HOST='d26013.ispservices.at'
CERT='ispservices.at.pem'

echo "--- SSL PEM - x509 cert fetch ---"
echo
echo -n "Download ..."

openssl s_client -connect d26013.ispservices.at:21 -showcerts -starttls ftp 2>/dev/null </dev/null \
  | sed -n '/-----BEGIN/,/-----END/p' > $CERT

echo " finished"

CA_URL=$(openssl x509 -in $CERT -text | sed -ne 's%\s\+CA Issuers - URI:\(http://[a-zA-Z0-9_\.\/]\+\)%\1%p')
if [ "X$CA_URL" != "X" ]; then
  echo $CA_URL
else
  echo "CA Issuer Extension not present in certificate!!!"
  echo "you need to manually download the issuer pem's and place them in"
  echo "CA.pem"
  exit 1
fi

CA_FILE=$(basename $CA_URL)
if [ -f $CA_FILE ]; then
  openssl x509 -inform DER -in $CA_FILE -out CA_new.pem
  rm $CA_FILE
else
  echo "file $CA_FILE not found"
  exit 1
fi

echo "verifying CA file and cert"
openssl verify -CAfile CA_new.pem $CERT

#cat <<EOF
#verify:
#openssl verify -CAfile CA_new.pem $CERT
#EOF
#openssl s_client -showcerts -connect $HOST:21 -starttls ftp
#echo openssl s_client -showcerts -connect $HOST:21 -starttls ftp
