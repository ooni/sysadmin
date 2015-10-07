#!/bin/sh
pass=$(openssl rand -hex 4)
crypted=$(echo -n $pass | openssl passwd -stdin)

echo $pass

cat > private/basic-auth <<EOF
{# $pass #}
admin:$crypted
EOF
