{% extends 'iptables.filter.part' %}

{% block svc %}
# http & https for public endpoints
-A INPUT -p tcp -m tcp --dport 80 --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT
-A INPUT -p tcp -m tcp --dport 443 --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT

# setup forwarding rules for hkgmetadb
-t nat -I PREROUTING -i eth0 -s $CLIENT -p udp --dport $PORT -j DNAT --to-destination $SERVER
-t nat -I POSTROUTING -o eth0 -s $CLIENT -d $SERVER -p udp --dport $PORT -j SNAT --to-source $BOUNCER
-I FORWARD -i eth0 -o eth0 -s $CLIENT -d $SERVER -p udp --dport $PORT -j ACCEPT
-I FORWARD -i eth0 -o eth0 -s $SERVER -d $CLIENT -p udp --sport $PORT -j ACCEPT

{% endblock %}
