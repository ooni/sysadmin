{% extends 'iptables.filter.part' %}

{% block svc %}
# http & https for public endpoints
-A INPUT -p tcp -m tcp --dport 80 --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT
-A INPUT -p tcp -m tcp --dport 443 --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT

# setup forwarding rules for hkgmetadb
-I PREROUTING -t nat -i eth0 -s {{ lookup('dig', 'hkgmetadb.infra.ooni.io/A') }} -p udp --dport 1194 -j DNAT --to-destination {{ lookup('dig', 'amsmetadb.ooni.nu/A') }}
-I POSTROUTING -t nat -o eth0 -s {{ lookup('dig', 'hkgmetadb.infra.ooni.io/A') }} -d {{ lookup('dig', 'amsmetadb.ooni.nu/A') }} -p udp --dport 1194 -j SNAT --to-source {{ lookup('dig', 'mia-ps-test.ooni.nu/A') }}
-I FORWARD -i eth0 -o eth0 -s {{ lookup('dig', 'hkgmetadb.infra.ooni.io/A') }} -d {{ lookup('dig', 'amsmetadb.ooni.nu/A') }} -p udp --dport 1194 -j ACCEPT
-I FORWARD -i eth0 -o eth0 -s {{ lookup('dig', 'amsmetadb.ooni.nu/A') }} -d {{ lookup('dig', 'hkgmetadb.infra.ooni.io/A') }} -p udp --sport 1194 -j ACCEPT

{% endblock %}
