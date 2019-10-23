{% extends 'iptables.filter.part' %}

{% block svc %}
# echo test helper
-A INPUT -p tcp -m tcp --dport 80 --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT
{% endblock %}
