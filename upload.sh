#!/bin/bash
BASE=$(dirname $0)
TARGETFOLDER='/webspace/httpdocs/ordimoerz.at'
SOURCEFOLDER="$BASE/tmp"

echo $BASE

if [ ! -d $SOURCEFOLDER ]; then
  echo "$SOURCEFOLDER does not exist"
  exit 1
fi

rm tmp/amp_index.html
rm tmp/html.index.html

./fix-the-amp.pl tmp/index.html
./fix-the-amp.pl tmp/impressum.html
mv tmp/index.html.ampfixed tmp/index.html
mv tmp/impressum.html.ampfixed tmp/impressum.html

echo "not uploading, but exiting"
exit

if [ -d scripts ]; then
  if [ -f scripts/credentials.sh ]; then
    source scripts/credentials.sh
  else
    echo "USER=" >> scripts/credentials.sh
    echo "PASS=" >> scripts/credentials.sh
  fi
fi

if [ "X$USER" == "X" ]; then
  echo USER not set
  exit 1
fi

lftp <<EOF
set ssl:ca-file /home/natoka/src/yo/CA.pem
open $HOST
user $USER $PASS
lcd $SOURCEFOLDER
mirror --reverse --verbose $SOURCEFOLDER $TARGETFOLDER
bye
EOF

if [ $? -ne 0 ]; then
cat <<EOF
--- WARNING SSL VERIFY FAILED ---
USE the scripts/fetch_ca.sh to fetch ca pem into CA_new.pem

verify authenticity and move then to CA.pem

EOF

fi
#openssl s_client -showcerts -connect $HOST:21 -starttls ftp
#echo openssl s_client -showcerts -connect $HOST:21 -starttls ftp
