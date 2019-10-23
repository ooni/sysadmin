{% extends 'iptables.filter.part' %}

{% block svc %}
# http & https for public endpoints
-A INPUT -p tcp -m tcp --dport 80 --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT
-A INPUT -p tcp -m tcp --dport 443 --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT
# postgresql
-A INPUT -s {{ lookup('dig', 'mia-ps-test.ooni.nu/A') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
{% endblock %}
