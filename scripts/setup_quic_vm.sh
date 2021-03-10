# Install QUIC / HTTP/3 forwarder
echo > /etc/motd
apt-get update
apt-get install -y --no-install-recommends fail2ban git etckeeper curl chrony
locale-gen --purge en_US.UTF-8
echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale
apt-get install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | apt-key add -
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee -a /etc/apt/sources.list.d/caddy-stable.list
apt-get update
apt-get install -y caddy
cat > /etc/caddy/Caddyfile <<EOF
{
 servers {
  protocol {
   allow_h2c
   experimental_http3
   strict_sni_host
  }
 }
}

quic.ooni.org:443 {
 reverse_proxy https://ams-pg.ooni.org
}
EOF
systemctl restart caddy.service
sleep 1
ss -nlptu | grep caddy

