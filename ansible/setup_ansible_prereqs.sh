#!/bin/bash
set -e
source /etc/os-release

if [ ! -f "/etc/apt/sources.list.bak" ];then
    mv /etc/apt/sources.list /etc/apt/sources.list.bak
fi

if [ "$VERSION_ID" -eq "7" ]; then
cat <<EOF > /etc/apt/sources.list
deb http://archive.debian.org/debian/ wheezy main contrib non-free
deb http://archive.debian.org/debian-security wheezy/updates main contrib non-free
EOF
fi

if [ "$VERSION_ID" -eq "8" ]; then
cat <<EOF > /etc/apt/sources.list
deb http://archive.debian.org/debian/ jessie main contrib non-free
deb http://archive.debian.org/debian-security jessie/updates main contrib non-free
EOF
fi

if [ "$VERSION_ID" -eq "9" ]; then
cat <<EOF > /etc/apt/sources.list
deb http://archive.debian.org/debian/ stretch main contrib non-free
deb http://archive.debian.org/debian/ stretch-proposed-updates main contrib non-free
deb http://archive.debian.org/debian-security stretch/updates main contrib non-free
EOF
fi

if [ "$VERSION_ID" -eq "10" ]; then
cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian/ buster main non-free contrib
deb http://deb.debian.org/debian/ buster-updates main non-free contrib
deb http://security.debian.org/ buster/updates main non-free contrib
EOF
fi

if [ "$VERSION_ID" -eq "11" ]; then
cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
deb http://security.debian.org/debian-security bullseye-security main contrib non-free
EOF
fi

if [ "$VERSION_ID" -eq "12" ]; then
cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian bookworm main contrib non-free-firmware non-free
deb http://deb.debian.org/debian bookworm-updates main contrib non-free-firmware non-free
deb http://security.debian.org/debian-security bookworm-security main contrib non-free-firmware non-free
EOF
fi

apt-get -qq update
apt-get -qq --yes install python3 python3-dnspython
touch /root/.ansible_prereqs_installed
