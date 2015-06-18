#!/bin/bash
set -x
FILE="/etc/apt/sources.list"
if [[ ! -f ${FILE}.orig ]]; then
    echo "Fixing apt so it doesn't complain..."
    sudo cp $FILE $FILE.orig
    sudo sed -i 's/security.ubuntu.com/10.0.100.2/g'  "$FILE"
    sudo sed -i 's/deb-src/#deb-src/g' "$FILE"
else
    echo "apt sources appears fixed already"
fi
EXCLFILE=/etc/apt/apt.conf.d/99proxy
TMPFILE=/tmp/99proxy
if [[ ! -f ${EXCLFILE} ]]; then
    cat <<EOF > ${TMPFILE}
Acquire::http::Proxy {
    10.0.100.2 DIRECT;
};
EOF

    sudo mv ${TMPFILE} ${EXCLFILE}
else
    echo "apt proxy appears fixed already"
fi
