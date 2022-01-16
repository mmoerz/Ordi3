#!/bin/bash
SCRIPTDIR=`dirname $0`
source $SCRIPTDIR/credentials.sh
CERT='ispservices.at.pem'

echo "--- SSL PEM - x509 cert fetch ---"
echo
echo -n "Download ..."

openssl s_client -connect $HOST:21 -showcerts -starttls ftp 2>/dev/null </dev/null \
  | sed -n '/-----BEGIN/,/-----END/p' > $CERT

echo " finished"

CA_URL=$(openssl x509 -in $CERT -text | sed -ne 's%\s\+CA Issuers - URI:\(http://[a-zA-Z0-9_\.\/]\+\)%\1%p')
if [ "X$CA_URL" != "X" ]; then
  echo "Issuer CA can be found at:"
  echo $CA_URL
  echo downloading:
  CA_FILE=$(basename $CA_URL)
  wget "$CA_URL" -O "$CA_FILE"
else
  echo "CA Issuer Extension not present in certificate!!!"
  echo "you need to manually download the issuer pem's and place them in"
  echo "CA.pem"
  exit 1
fi

CA_FILE=$(basename $CA_URL)
CA_NAME=${CA_FILE%.crt}.pem
if [ -f $CA_FILE ]; then
  echo "converting DER file $CA_FILE into pem file $CA_NAME"
  openssl x509 -inform DER -in $CA_FILE -out "$CA_NAME"
  rm $CA_FILE
else
  echo "file $CA_FILE not found"
  exit 1
fi

echo "verifying CA file and cert"
openssl verify -CAfile $CA_NAME $CERT

#cat <<EOF
#verify:
#openssl verify -CAfile CA_new.pem $CERT
#EOF
#openssl s_client -showcerts -connect $HOST:21 -starttls ftp
#echo openssl s_client -showcerts -connect $HOST:21 -starttls ftp
