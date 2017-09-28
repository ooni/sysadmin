{% extends 'iptables.filter.part' %}
{% block svc %}
-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
{% endblock %}
