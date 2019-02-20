{% extends 'iptables.filter.part' %}
{% block svc %}
# OONITestHelper
-A INPUT -p tcp -m tcp --dport 9001 -j ACCEPT
{% endblock %}
