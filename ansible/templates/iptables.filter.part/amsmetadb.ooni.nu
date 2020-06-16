{% extends 'iptables.filter.part' %}
{% block svc %}
# postgresql
-A INPUT -s {{ lookup('dig', 'ams-api.ooni.nu/A') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
-A INPUT -s {{ lookup('dig', 'fastpath.ooni.nu/A') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
-A INPUT -s {{ lookup('dig', 'ams-jupyter.ooni.nu/A') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
# Incoming Prio traffic from probe services
-A INPUT -s {{ lookup('dig', 'mia-ps2.ooni.nu') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
-A INPUT -s {{ lookup('dig', 'hkg-ps.ooni.nu') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
-A INPUT -s {{ lookup('dig', 'ams-ps.ooni.nu') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
-A INPUT -s {{ lookup('dig', 'ams-ps2.ooni.nu') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT

# allow openvpn connections
-A INPUT -s {{ lookup('dig', 'hkgmetadb.infra.ooni.io/A') }}/32 -p udp --dport 1194 -j ACCEPT
-A INPUT -s {{ lookup('dig', 'mia-ps-test.ooni.nu/A') }}/32 -p udp --dport 1194 -j ACCEPT
{% endblock %}
