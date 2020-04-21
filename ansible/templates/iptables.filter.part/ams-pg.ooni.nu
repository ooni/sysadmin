{% extends 'iptables.filter.part' %}
{% block svc %}
# postgresql
-A INPUT -s {{ lookup('dig', 'ams-api.ooni.nu/A') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
-A INPUT -s {{ lookup('dig', 'fastpath.ooni.nu/A') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
{% endblock %}
