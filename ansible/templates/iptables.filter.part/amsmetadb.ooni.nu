{% extends 'iptables.filter.part' %}
{% block svc %}
# postgresql
-A INPUT -s {{ lookup('dig', 'api.ooni.io/A') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
{% endblock %}
